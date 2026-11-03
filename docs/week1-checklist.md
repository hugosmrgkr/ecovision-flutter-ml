# Week 1 verification checklist

Mark complete **only after running checks locally**.

- [ ] Confirm `python --version`, `py -0p`, `git --version`, `flutter --version`, `flutter doctor -v`, `nvidia-smi`, `wsl --status` and record the actual results.
- [ ] Verify Python 3.11 and create `.venv`.
- [ ] Install exploration requirements and select local Jupyter kernel.
- [ ] Generate `mobile/` using Flutter CLI; run `flutter test` and `flutter run` on Android.
- [ ] Download TrashNet from its source and place the six class folders under `ml/data/raw/trashnet/`.
- [ ] Run dataset audit and inspect invalid images and exact duplicates.
- [ ] Review near-duplicates, label quality and domain shift manually.
- [ ] Run the exploration notebook and save reproducible observations.
- [ ] Run `python -m pytest ml/tests -q`.
- [ ] Create a Git repository and make the first commit after checking `git status` for private data.

## Week 1 acceptance criteria

- Android Flutter starter works on a device/emulator.
- Notebook runs using local Python environment.
- Source-only repo excludes raw images and secrets.
- Dataset counts and quality findings are recorded from actual inspection.
- Unit tests pass on user's laptop.
- GPU training in WSL2 is deferred until ready for Week 2; no GPU performance is claimed.

## Important

No completed checkbox is implied by the existence of this scaffold. The files have been generated for local use; local system setup, dataset audit and Android execution are not yet verified.
