# Known Issues

Findings from a structural survey of the codebase (2026-07-13). These are
observations, not fixes — per project convention, existing pipelines are
treated as trusted infrastructure and are not refactored without explicit
instruction. Flagging here so they're visible before anyone builds on top of
them.

## Code duplication

- **`start_analog_recording.m` / `stop_analog_recording.m`** exist
  byte-identically in both `SI_user_functions/` and
  `SI_scripts/Record_analog_and_imaging_data/`. This looks intentional
  (`SI_user_functions/` is likely the deployment copy ScanImage's path
  expects; the other is the working copy) but means any fix must be applied
  in both places or they will silently diverge.
- **`data_logger_grab.m`**, **`data_logger_init_analog_acq_ni.m`**, and
  **`run_analog_acquisition.m`** are three highly overlapping
  implementations of "set up NI analog channels + start a ScanImage grab."
  It's not obvious from the code alone which is canonical/current versus
  superseded. Worth clarifying before extending the NI acquisition path.

## Function name collision

- **`myAnalogInputTask.m`** and **`myAnalogInputTask_template.m`** (both in
  `SI_scripts/`) each define a function named `myAnalogInputTask`. Only one
  can be resolved on the MATLAB path at a time — having both on the path
  means whichever shadows the other wins silently, with no warning at call
  time.

## Likely bugs

- **`util_get_si_acq_parameters.m`**: `step_size`, `frames_per_slice`,
  `z_start`, and `z_end` are all assigned the value of `num_slices` (appears
  to be a copy-paste error). Any code reading those four fields from
  `acq_settings` is getting wrong values.
- **`util_post_acq_update.m`**: contains an empty `if ~ismember(...)`
  branch — likely an unfinished TODO rather than a functional no-op.
- **`util_post_acq_dialog.m`**: the file is named for a post-acquisition
  dialog but defines a function called `choosedialog` with a generic
  "Select a color" prompt and no visible button/output wiring — looks like
  an unfinished stub left over from a MATLAB dialog-box template.

## Missing dependency

- **`parse_analog_data.m`** calls `groupSquareWaveBursts`, which does not
  exist anywhere in this repository. Running this script as-is will error
  unless that function is supplied from elsewhere.

## Explicit dev/exploratory code

- **`DEV_RT_HR.m`** is explicitly prefixed `DEV_` and loads a hardcoded HDF5
  path — a sandbox script, not part of the production pipeline. Per
  project convention (`explore/` vs `analysis/` vs `src/` standards), this
  should not be held to production expectations, but also should not be
  imported by other scripts as if it were.
- **`analyze_calcium_and_ecg.m`** has commented-out/incomplete sections
  (e.g., a manual spike-table build) — exploratory, not confirmatory,
  analysis.
- Both `data_logger_grab.m` and `data_logger_init_analog_acq_ni.m` headers
  note "To do — functionalize with argument to control VDAQ and NI
  systems," i.e. the authors already flagged this duplication as unfinished
  work.

## NWB compliance

Per this lab's data-directory conventions, pipelines that read/write
experimental data should be assessed for NWB compatibility.
`util_write_metadata_to_xml.m` writes a custom XML sidecar shaped like an
NWB record (project/subject/session/acquisition fields) but does not use
`pynwb`/MatNWB and produces a plain XML file, not a `.nwb` container.
Status: `[NWB: partial]`. If NWB output is ever required downstream, this
sidecar format would need re-engineering rather than incremental extension —
worth deciding early if that's a future requirement.
