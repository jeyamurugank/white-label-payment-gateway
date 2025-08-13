import { logger } from './logger'; export function audit(event:string, details:any){ logger.info({ event, details, ts: new Date().toISOString() }); }
