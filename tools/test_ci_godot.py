"""Release gate contract: retry only a native SIGABRT without script errors."""
from pathlib import Path
import os
import subprocess
import tempfile
import unittest

WRAPPER = Path(__file__).with_name('ci_godot.sh')


class ReleaseGateTests(unittest.TestCase):
    def probe(self, exits, messages=None):
        with tempfile.TemporaryDirectory(prefix='tomatocut-gate-') as folder:
            directory = Path(folder)
            engine = directory / 'engine'
            counter = directory / 'calls'
            engine.write_text('#!/usr/bin/env python3\n'
                              'from pathlib import Path\nimport sys\n'
                              f'p=Path({str(counter)!r})\n'
                              'n=int(p.read_text()) if p.exists() else 0\np.write_text(str(n+1))\n'
                              f'print({(messages or ["engine output"] * len(exits))!r}[n])\n'
                              f'sys.exit({exits!r}[n])\n')
            engine.chmod(0o755)
            result = subprocess.run([str(WRAPPER), '--headless'], env={**os.environ, 'TOMATOCUT_GODOT_BIN': str(engine)}, text=True, capture_output=True)
            return result.returncode, int(counter.read_text()), result.stdout

    def test_native_abort_retries_once_and_reports_evidence(self):
        status, calls, output = self.probe([134, 0], ['native allocator aborted', 'RESULT: 1173 checks, 0 failures'])
        self.assertEqual((status, calls), (0, 2))
        self.assertIn('::warning::Godot exited 134', output)
        self.assertIn('native allocator aborted', output)

    def test_assertion_failure_never_retries(self):
        self.assertEqual(self.probe([1], ['FAIL: incorrect payout'])[:2], (1, 1))

    def test_repeated_native_abort_still_fails(self):
        self.assertEqual(self.probe([134, 134])[:2], (134, 2))

    def test_zero_exit_with_script_error_still_fails(self):
        self.assertEqual(self.probe([0], ['SCRIPT ERROR: invalid object'])[:2], (1, 1))

    def test_abort_with_script_error_never_retries(self):
        self.assertEqual(self.probe([134], ['ERROR: bad resource'])[:2], (1, 1))


if __name__ == '__main__':
    unittest.main()
