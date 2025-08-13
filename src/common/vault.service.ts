
import { getSecretFromVault } from './vault.client';

/**
 * VaultService - fetch secrets from Vault or fallback to environment variables.
 * Call: await vault.get('secret/path', 'key')
 */
export class VaultService {
  async get(path: string, key: string) {
    // Try Vault first
    try {
      const val = await getSecretFromVault(path, key, 30);
      if (val !== undefined) return val;
    } catch (e) { /* ignore and fallback */ }
    // Fallback to environment variables (existing behavior)
    const envKey = `${path}:${key}`;
    return process.env[envKey.replace(/[:/]/g, '_').toUpperCase()] || undefined;
  }
}
