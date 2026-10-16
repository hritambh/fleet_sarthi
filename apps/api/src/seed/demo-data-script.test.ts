import { spawnSync } from 'node:child_process';
import { chmodSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';

/**
 * infra/render/demo-data.sh, the demo-data step of the API's start on Render.
 * A failed demo refresh (on 2026-10-17, the B2 key refused the seed's photo
 * uploads with AccessDenied) once stopped the API from starting; this checks
 * it can't again. `node` is a stub on the PATH that records its arguments and
 * exits with FAKE_NODE_EXIT.
 */
const script = resolve(
  dirname(fileURLToPath(import.meta.url)),
  '../../../../infra/render/demo-data.sh',
);

let bin: string;
let calls: string;

beforeEach(() => {
  bin = mkdtempSync(join(tmpdir(), 'demo-data-'));
  calls = join(bin, 'calls.txt');
  writeFileSync(calls, '');
  const fakeNode = join(bin, 'node');
  writeFileSync(
    fakeNode,
    `#!/usr/bin/env bash\necho "$*" >> "${calls}"\nexit "\${FAKE_NODE_EXIT:-0}"\n`,
  );
  chmodSync(fakeNode, 0o755);
});

afterEach(() => {
  rmSync(bin, { recursive: true, force: true });
});

function run(env: Record<string, string>) {
  const result = spawnSync('bash', [script], {
    env: { PATH: `${bin}:/usr/bin:/bin`, HOME: process.env['HOME'] ?? '/tmp', ...env },
    encoding: 'utf8',
  });
  return {
    status: result.status,
    stderr: result.stderr,
    calls: readFileSync(calls, 'utf8').trim().split('\n').filter(Boolean),
  };
}

describe('the demo-data step of the API start (infra/render/demo-data.sh)', () => {
  it('does nothing when no demo switch is on', () => {
    const r = run({});
    expect(r.status).toBe(0);
    expect(r.calls).toEqual([]);
  });

  it('refreshes a stale demo with DEMO_REFRESH_DAILY', () => {
    const r = run({ DEMO_REFRESH_DAILY: 'true' });
    expect(r.status).toBe(0);
    expect(r.calls).toEqual(['--enable-source-maps dist/seed/demo-refresh-cli.js --if-stale']);
  });

  it('forces a rebuild with DEMO_REFRESH_FORCE', () => {
    const r = run({ DEMO_REFRESH_DAILY: 'true', DEMO_REFRESH_FORCE: 'true' });
    expect(r.calls).toEqual(['--enable-source-maps dist/seed/demo-refresh-cli.js']);
  });

  it('a failed refresh (e.g. S3 AccessDenied) still lets the API start', () => {
    const r = run({ DEMO_REFRESH_DAILY: 'true', FAKE_NODE_EXIT: '1' });
    expect(r.status).toBe(0);
    expect(r.stderr).toContain('the demo refresh failed');
    expect(r.stderr).toContain('starting the API anyway');
  });

  it('a failed seed still lets the API start, and the refresh is still tried', () => {
    const r = run({ SEED_DEMO_DATA: 'true', DEMO_REFRESH_DAILY: 'true', FAKE_NODE_EXIT: '1' });
    expect(r.status).toBe(0);
    expect(r.calls).toHaveLength(2);
    expect(r.stderr).toContain('the demo seed failed');
    expect(r.stderr).toContain('the demo refresh failed');
  });
});
