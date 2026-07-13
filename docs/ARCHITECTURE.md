# Architecture

## Purpose

Data_logger is a MATLAB application that automates data-structure and metadata
bookkeeping for ScanImage-based imaging experiments. It is not an acquisition
engine itself — ScanImage (and, optionally, an NI-DAQ or VDAQ analog
recorder) does the actual data acquisition. Data_logger's job is to:

- track experimental subjects, sessions, and acquisitions in plain-text CSV
  tables so the project stays greppable/spreadsheet-friendly and portable,
- generate consistent, structured file/directory names for each acquisition,
- write a metadata sidecar (XML, NWB-shaped) alongside each acquisition,
- optionally wire up simultaneous analog recording (ECG/TTL/air-puff/etc.)
  around a ScanImage grab.

It can also be used purely as a directory/metadata organizer, without the
analog-recording or even the ScanImage integration.

## Components

```
Data_logger/            Main MATLAB App Designer application ("the app")
SI_user_functions/      ScanImage "user function" callbacks (NI-DAQ path)
SI_scripts/             Standalone ScanImage user functions + analysis scripts
SI_scripts/Record_analog_and_imaging_data/
                         Analog-recording pipeline (setup, callbacks, offline analysis)
project.yml              Example/template project config (per-project, lives in PROJECT_ROOT_DIR)
```

### 1. `Data_logger/` — the app

`SI_data_logger.mlapp` is a MATLAB App Designer GUI and the single entry
point. It owns an `app` object (project root dir, current subject/session/
acquisition selections, GUI field values) that is threaded through nearly
every function in this directory as the first argument. The rest of the
directory is plain `.m` helper/callback functions the app calls:

- **Project lifecycle**: `action_project_create.m` (writes `project.yml`),
  `util_project_load.m` / `util_validate_yml_in_rootdir.m` (load project +
  populate GUI dropdowns from it).
- **Subjects**: `util_add_subject.m`, `util_get_subject.m` — append rows to
  `subjects.csv`.
- **Sessions**: `util_get_session_parameters.m`, `util_create_session_name.m`,
  `util_log_session.m`, `util_preview_session_filestructure.m` — build a
  BIDS-like session identifier/directory tree (`ophys/`, `anat/`,
  `derivates/`) and append rows to `sessions.csv`.
- **Acquisitions**: `util_grab.m` (the "start acquisition" entry point),
  `util_get_si_acq_parameters.m` (reads live ScanImage `hSI` state),
  `util_log_acquisition.m` (appends `acquisitions.csv`),
  `util_update_acq_mode.m` (toggles ScanImage stack mode),
  `util_write_metadata_to_xml.m` (writes the per-acquisition XML sidecar).
- **Analog-acquisition dispatch**: `data_logger_init_analog_acq_ni.m` /
  `data_logger_init_analog_acq_vdaq.m` / `data_logger_grab.m` — system-specific
  init scripts `util_grab.m` calls into when analog recording is enabled.
  These are the files a new lab/rig is expected to edit (see README
  "Installation").
- **Generic helpers**: `adjust_readtable_timeoptions.m`,
  `append_fields_to_structure.m`, `append_uneven_tables.m`,
  `util_create_filename.m`, `util_validate_description_text.m`,
  `util_post_acq_dialog.m`, `util_post_acq_update.m`.

### 2. `SI_user_functions/`

Copies of `start_analog_recording.m` / `stop_analog_recording.m` meant to be
placed on the MATLAB path so ScanImage can call them as registered "user
functions" on acquisition events (`acqModeArmed`, `acqModeDone`, `acqAbort`).
See `docs/KNOWN_ISSUES.md` for how this relates to the near-identical copies
under `SI_scripts/Record_analog_and_imaging_data/`.

### 3. `SI_scripts/`

Standalone ScanImage user-function callbacks and small utilities that aren't
part of the `Data_logger` app proper: `change_si_filename.m` (manual filename
template), `extract_analog_data.m` and `myAnalogInputTask*.m` (alternative
analog-capture strategies not routed through `Data_logger`), `set_dark_mode.m`
(plot styling), `testSliceTime.m` (timing diagnostics), and
`display_last_analog_acq.m` (post-acquisition ECG/HR/TTL plot).

### 4. `SI_scripts/Record_analog_and_imaging_data/`

The analog-recording pipeline used when `Data_logger` is configured for
simultaneous imaging + analog acquisition (e.g. ECG for heart-rate gating):

- **Setup**: `set_analog_recording.m` creates the NI DAQ session and attaches
  `saveData.m` (CSV writer) and `plotData.m` (live ECG/HR/TTL plot) as
  `DataAvailable` listeners.
- **Lifecycle callbacks**: `start_analog_recording.m` / `stop_analog_recording.m`.
- **Peak/HR detection**: `find_R_peaks.m` — the shared ECG R-wave detector
  used by nearly every script in this folder.
- **Offline analysis** (exploratory, not part of the live pipeline):
  `analyze_ecg.m`, `analyze_calcium_and_ecg.m`, `parse_analog_data.m`,
  `DEV_RT_HR.m` (explicit dev sandbox).

## Data flow (typical session)

1. User creates or loads a project (`project.yml` in `PROJECT_ROOT_DIR`),
   populating the GUI's condition/genotype/virus/anesthesia/etc. dropdowns.
2. User adds a subject → appended to `subjects.csv`.
3. User fills in session parameters (condition, FOV, timepoint, ...) →
   `util_create_session_name.m` derives a session ID and directory tree.
4. User starts a grab → `util_grab.m` builds the filename, configures
   ScanImage logging, optionally dispatches to the NI/VDAQ analog-init
   script, then calls `util_log_session.m`, `util_log_acquisition.m`, and
   `util_write_metadata_to_xml.m`.
5. If analog recording is enabled, `set_analog_recording.m` starts a
   parallel NI-DAQ session; `start_analog_recording.m` /
   `stop_analog_recording.m` are invoked by ScanImage as user functions to
   bracket the acquisition; `display_last_analog_acq.m` shows the result.
6. All bookkeeping lives in three CSVs (`subjects.csv`, `sessions.csv`,
   `acquisitions.csv`) plus one XML sidecar per acquisition — the project
   tree can be relocated as a unit since paths are stored relative to
   `PROJECT_ROOT_DIR`.

## How to run

1. Clone/download this repo and add it to the MATLAB path.
2. Install dependencies (see below).
3. Create a `project.yml` in your chosen `PROJECT_ROOT_DIR` (see the
   template at the repo root, or use the app's "create project" action).
4. For NI-DAQ analog recording, edit `data_logger_init_analog_acq_ni.m` and
   add `SI_user_functions/` to the MATLAB path. For VDAQ, edit
   `data_logger_init_analog_acq_vdaq.m`.
5. Launch `Data_logger/SI_data_logger.mlapp` from MATLAB (with ScanImage
   running if using live acquisition parameters / `SI-Online` app mode).

## Key dependencies

- MATLAB App Designer runtime (ships with MATLAB).
- [yaml (MathWorks File Exchange #106765)](https://www.mathworks.com/matlabcentral/fileexchange/106765-yaml)
  — required for `project.yml` read/write.
- [xml_io_tools (File Exchange #12907)](https://www.mathworks.com/matlabcentral/fileexchange/12907-xml_io_tools)
  — only required on MATLAB releases before R2020b; R2020b+ uses built-in
  `writestruct`.
- ScanImage (`hSI` handle, `dabs.resources.ResourceStore`) — required for
  live acquisition-parameter capture and for the VDAQ/NI analog-recording
  paths; not required for pure directory/metadata bookkeeping.
- MATLAB Data Acquisition Toolbox (`daq.createSession('ni')`) — required for
  NI-DAQ analog recording.

## NWB status

`[NWB: partial]` — `util_write_metadata_to_xml.m` writes an XML sidecar
shaped like an NWB metadata record (project/subject/session/acquisition
fields) but does not use `pynwb`/MatNWB and does not produce an actual
`.nwb` file. See `docs/KNOWN_ISSUES.md`.
