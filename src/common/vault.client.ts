
/**
 * Minimal Vault client wrapper.
 * - Reads VAULT_ADDR and VAULT_TOKEN from environment (or Kubernetes service account via Vault Agent)
 * - Provides getSecret(path, key) -> string | undefined
 * - Caches values in-memory with TTL to reduce calls.
 *
 * NOTE: For production use, use official clients or vault-agent sidecar + Kubernetes Auth.
 */

import fetch from 'node-fetch';

const VAULT_ADDR = process.env.VAULT_ADDR || process.env.VAULT_URL;
const VAULT_TOKEN = process.env.VAULT_TOKEN; // or use Vault Agent injected token path

const CACHE: Record<string, { value: any; expiresAt: number }> = {};

export async function getSecretFromVault(path: string, key?: string, ttlSec = 60) {
  if (!VAULT_ADDR || !VAULT_TOKEN) return undefined;
  const cacheKey = `${path}:${key}`;
  const now = Date.now();
  if (CACHE[cacheKey] && CACHE[cacheKey].expiresAt > now) {
    return CACHE[cacheKey].value;
  }
  const url = `${VAULT_ADDR.replace(/\/$/,'')}/v1/${path}`;
  const res = await fetch(url, { headers: { 'X-Vault-Token': VAULT_TOKEN } });
  if (!res.ok) return undefined;
  const data = await res.json();
  // KV v2 compatibility: secret in data.data.data
  const secretData = (data && data.data && (data.data.data || data.data)) || data;
  const val = key ? secretData[key] : secretData;
  CACHE[cacheKey] = { value: val, expiresAt: now + ttlSec * 1000 };
  return val;
}
