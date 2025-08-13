
import Redis from 'ioredis';
import { NestMiddleware, Injectable, TooManyRequestsException } from '@nestjs/common';

const SCRIPT = `
-- KEYS[1] = bucket key
-- ARGV[1] = capacity
-- ARGV[2] = refill_per_sec
-- ARGV[3] = now (ms)
-- Returns: {allowed(0/1), tokens_left, reset_ms}
local key = KEYS[1]
local capacity = tonumber(ARGV[1])
local refill = tonumber(ARGV[2])
local now = tonumber(ARGV[3])

local data = redis.call('HMGET', key, 'tokens', 'last')
local tokens = tonumber(data[1])
local last = tonumber(data[2])

if tokens == nil then
  tokens = capacity
  last = now
else
  local delta = math.max(0, now - last) / 1000.0
  tokens = math.min(capacity, tokens + delta * refill)
  last = now
end

local allowed = 0
if tokens >= 1 then
  allowed = 1
  tokens = tokens - 1
end

redis.call('HMSET', key, 'tokens', tokens, 'last', last)
redis.call('PEXPIRE', key, math.ceil((capacity / refill) * 1000))

local reset_ms = math.ceil((1 - tokens) / refill * 1000)
return {allowed, tokens, reset_ms}
`;

@Injectable()
export class RedisRateLimiterMiddleware implements NestMiddleware {
  private redis: Redis;
  private sha?: string;
  private capacity: number;
  private refill: number;

  constructor() {
    const url = process.env.REDIS_URL || 'redis://localhost:6379';
    this.redis = new Redis(url);
    this.capacity = parseInt(process.env.RATE_LIMIT_CAPACITY || '100', 10);
    this.refill = parseFloat(process.env.RATE_LIMIT_REFILL_PER_SEC || '1');
    this.redis.script('LOAD', SCRIPT).then(sha => this.sha = sha).catch(()=>{});
  }

  async use(req: any, res: any, next: any) {
    const keyPart = (req.headers['x-api-key'] || req.ip || 'anon').toString();
    const key = `rl:${keyPart}`;
    const now = Date.now();
    try {
      const result: any = await this.redis.evalsha(this.sha || '', 1, key, this.capacity, this.refill, now);
      const allowed = Array.isArray(result) ? result[0] : 1;
      if (allowed === 1) return next();
    } catch {
      // Fallback to allowing if redis/script not ready
      return next();
    }
    throw new TooManyRequestsException('rate limit exceeded');
  }
}
