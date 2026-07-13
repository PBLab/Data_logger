# Function Reference

Per-file signatures and descriptions, grouped by directory. See
[ARCHITECTURE.md](ARCHITECTURE.md) for how these fit together, and
[KNOWN_ISSUES.md](KNOWN_ISSUES.md) for caveats flagged during this survey
(marked with ⚠️ below).

## `Data_logger/` — main app package

`SI_data_logger.mlapp` — MATLAB App Designer file (binary). Main GUI entry
point; owns the `app` object passed through nearly every function below.

| File | Signature | Description |
|---|---|---|
| `action_project_create.m` | `status = action_project_create(app)` | Gathers project metadata (id, lab, institution, experimenter, protocol, description) from GUI fields and writes `project.yml` via `yaml.dumpFile`. Refuses to overwrite an existing project. |
| `adjust_readtable_timeoptions.m` | `opts = adjust_readtable_timeoptions(path_to_table, table_vars, fmt)` | Builds `detectImportOptions`/`setvaropts` options to force a datetime format on specified table columns before `readtable`. |
| `append_fields_to_structure.m` | `s1 = append_fields_to_structure(s1, s2)` | Copies all fields from struct `s2` into struct `s1`. |
| `append_uneven_tables.m` | `T1 = append_uneven_tables(T1, T2)` | Pads `T1` with empty/NaN/NaT/`'None'` columns to match `T2`'s schema, then vertically concatenates. Used when new acquisition columns appear that older CSV rows don't have. |
| `data_logger_grab.m` | script | Configures NI-style `analog_channels` (Dev1/Dev2) via `set_analog_recording`, sets up ECG/HR global buffers, registers `stop_analog_recording` as an `acqModeDone` user function, calls `hSI.startGrab` twice. ⚠️ Header says "VDAQ" but body is NI-specific; largely overlaps with `data_logger_init_analog_acq_ni.m`. |
| `data_logger_init_analog_acq_ni.m` | script | NI-DAQ acquisition init: configures `analog_channels`, ECG/HR thresholds/buffers, live plots (ECG/HR/TTL), registers `start_analog_recording`/`stop_analog_recording` on `acqModeArmed`/`acqModeDone`/`acqAbort`, starts `hSI.startGrab`. Edit this file to adapt to your NI rig. |
| `data_logger_init_analog_acq_vdaq.m` | script | Minimal VDAQ analog-recorder init via `dabs.resources.ResourceStore('AnalogDataRecorder')`; sets sample rate/filename/directory/trigger; registers `stop_analog_recording` on `acqModeDone`. Edit this file to adapt to your VDAQ rig. |
| `util_add_subject.m` | `status = util_add_subject(app)` | Validates mandatory subject fields (ID, DOB, sex), checks for duplicate animal ID in `subjects.csv`, appends new subject row, writes CSV, refreshes subject dropdown. |
| `util_create_filename.m` | `filename = util_create_filename(app)` | Builds a structured base filename from subject/acq/condition/FOV/timepoint/stim fields. |
| `util_create_session_name.m` | `[session_str, session_dir_str] = util_create_session_name(app, create_directories)` | Builds a BIDS-like session ID and nested directory path from condition/FOV/timepoint/anesthesia/pharmacology/stim fields; optionally creates `ophys`/`anat`/`derivates` subfolders. |
| `util_get_session_parameters.m` | `util_get_session_parameters(app)` | Pulls session-related GUI field values (root dir, subject, timepoint, condition, anesthesia, FOV, labeling, pharmacology, stim) into `app` properties. |
| `util_get_si_acq_parameters.m` | script | Reads live ScanImage (`hSI`) acquisition parameters (ROI, scan rate, motor/sample position, beam power, stack settings) into global `acq_settings`. ⚠️ `step_size`/`frames_per_slice`/`z_start`/`z_end` are all assigned `num_slices` (copy-paste bug). |
| `util_get_subject.m` | `subject = util_get_subject(app)` | Packs subject GUI fields (id, species, genotype, strain, sex, weight, DOB, surgery info, virus, description) into a struct. |
| `util_grab.m` | `status = util_grab(app)` | Core "start acquisition" routine: validates session initialized, builds filename/paths by acq type (Movie/Arbitrary Scan/Stack), configures ScanImage logging via `evalin('base',...)`, dispatches to NI/VDAQ analog-init scripts if enabled, logs session/acquisition, writes XML metadata, increments `ACQ_ID`. |
| `util_log_acquisition.m` | `[this_acq, status] = util_log_acquisition(app, grab_start_timestamp)` | Builds an acquisition record (mode, scanner, objective, DAQ, description, plus live SI params in `SI-Online` mode), appends/creates `acquisitions.csv`, updates the acquisition-ID dropdown. |
| `util_log_session.m` | `[this_session, status] = util_log_session(app)` | Builds a session record (session/acq/project/subject IDs, condition, fov, timepoint, anesthesia, labeling, pharmacology, stim, description, path) and appends/creates `sessions.csv`. |
| `util_post_acq_dialog.m` | `choice = choosedialog` | ⚠️ Filename/function name mismatch — file is `util_post_acq_dialog.m` but defines `choosedialog`. Builds a generic modal dialog ("Select a color"); body appears incomplete (dialog + text control only, no button/output logic). |
| `util_post_acq_update.m` | `status = util_post_acq_update(app)` | Loads `sessions.csv`, locates the row matching the selected acquisition ID, updates `comments`/`keep_session_for_analysis` from GUI, rewrites CSV. ⚠️ Contains an empty `if ~ismember(...)` branch (dead code/TODO). |
| `util_preview_session_filestructure.m` | `util_preview_session_filestructure(app)` | Computes the session name/dir without creating folders, builds and displays an ASCII tree preview via `uialert`. |
| `util_project_load.m` | `status = util_project_load(app)` | Loads `project.yml`, populates Project/Session/Subject GUI dropdowns; loads `subjects.csv`/`sessions.csv` if present to seed the subject dropdown and next `ACQ_ID`. |
| `util_update_acq_mode.m` | `util_update_acq_mode(app)` | Toggles ScanImage's `hStackManager.enable` based on selected acquisition mode (Movie/Stack/Arbitrary Scan). |
| `util_validate_description_text.m` | `str = util_validate_description_text(ori_str)` | Sanitizes free-text description: replaces commas with semicolons, appends a trailing period. |
| `util_validate_yml_in_rootdir.m` | `status = util_validate_yml_in_rootdir(app)` | Checks whether `project.yml` exists in the project root; alerts user if missing. |
| `util_write_metadata_to_xml.m` | `status = util_write_metadata_to_xml(app, session, acq_params)` | Assembles project/subject/session/acq_params into a combined struct and writes it as an XML sidecar (`writestruct` on R2020b+, legacy `xml_write` otherwise). |

## `SI_user_functions/`

| File | Signature | Description |
|---|---|---|
| `start_analog_recording.m` | `start_analog_recording(~,~)` | ScanImage user-function stub; starts the background analog DAQ session (`dq.startBackground()`) via `evalin('base',...)`. |
| `stop_analog_recording.m` | `stop_analog_recording(src, event, varargin)` | ScanImage user-function stub; stops the DAQ session, closes files, disables the user-function config, triggers `display_last_analog_acq`. |

⚠️ Both files are byte-identical to their namesakes in
`SI_scripts/Record_analog_and_imaging_data/` — see KNOWN_ISSUES.md.

## `SI_scripts/`

| File | Signature | Description |
|---|---|---|
| `change_si_filename.m` | script | Builds a structured ScanImage log filename (exptype, mouse, day, fov, condition + auto-captured magnification/pixels/framerate/bidirectional flag) and sets `hSI.hScan2D.logFileStem`. Manual-edit template (hardcoded values). |
| `display_last_analog_acq.m` | `display_last_analog_acq(analog_file_name)` | Loads a completed analog CSV (Time/ECG/TTL/AirPuff), computes R-peaks and HR via `find_R_peaks`, plots ECG+peaks/HR/TTL/AirPuff in a dark-mode docked figure. |
| `extract_analog_data.m` | `extract_analog_data(src, evt, varargin)` | ScanImage user-function that repurposes unused imaging channels (ch4 = puff, ch3 = run) to capture per-frame analog signals into a buffer, applies a frame delay correction, writes `_analog.txt` on acquisition done/abort. |
| `myAnalogInputTask.m` | `myAnalogInputTask(src, evt, varargin)` (+ nested `myCallback`) | ScanImage user-function using legacy NI-DAQmx `most.util.safeCreateTask` to stream 2 AI channels (Dev1, ch0/7) at 1kHz, writing samples to file and live-plotting. |
| `myAnalogInputTask_template.m` | `myAnalogInputTask(src, evt)` (+ nested `myCallback`) | ⚠️ Simplified/template variant targeting a PXI DAQ card (4 channels), triggered off ScanImage's frame clock; plot-only, no file writing. Defines the **same function name** as the file above. |
| `set_dark_mode.m` | `set_dark_mode(h2fig)` | Applies a dark background/axis color scheme to a given figure handle. |
| `testSliceTime.m` | `testSliceTime(src, evt, varargin)` | ScanImage user-function/dev diagnostic timing slice-to-acquisition-start intervals via `tic`/`toc` and MATLAB `profile`. |

## `SI_scripts/Record_analog_and_imaging_data/`

| File | Signature | Description |
|---|---|---|
| `DEV_RT_HR.m` | script (dev sandbox) | Loads a saved ECG CSV and hardcoded HDF5 path, simulates real-time HR estimation by streaming 100-sample chunks through a rolling buffer and `find_R_peaks`, plotting ECG and HR history live. |
| `analyze_calcium_and_ecg.m` | script | Offline analysis: loads ECG+TTL CSV and calcium `F_dff` HDF5, crops to imaging window, finds R-peaks, computes instantaneous HR, builds a spike raster and heartbeat-triggered PSTH. Contains commented-out/incomplete sections — exploratory. |
| `analyze_ecg.m` | script | Offline post-hoc analysis of a single saved analog CSV: crops to imaging window via TTL threshold, finds R-peaks, computes/plots instantaneous HR. |
| `find_R_peaks.m` | `[locs_Rwave, locs_Swave] = find_R_peaks(ECG, ecg_R_vol_thresh, mean_peak_dist)` | Detects ECG R-wave (and optionally S-wave) peak locations via `findpeaks`. Core dependency used by nearly every ECG/HR script in the project. |
| `parse_analog_data.m` | script | Parses a saved `*analog.csv`: crops by TTL threshold, derives a frame-to-time lookup table from TTL edges, detects/groups stimulus voltage levels into bouts, writes `_stims.csv` and `_lut.csv`. ⚠️ Calls `groupSquareWaveBursts`, which is not present in this repo. |
| `plotData.m` | `plotData(event)` | DAQ `DataAvailable` listener callback: rolls incoming ECG/TTL/air-puff samples into global ring buffers, updates live plot lines, recomputes HR via `find_R_peaks`. |
| `run_analog_acquisition.m` | script | Sets up NI analog channels via `set_analog_recording`, ECG/HR buffers/plots, registers `start_analog_recording`/`stop_analog_recording`, starts `hSI.startGrab`. ⚠️ Near-duplicate of `Data_logger/data_logger_init_analog_acq_ni.m` and `data_logger_grab.m`. |
| `saveData.m` | `saveData(fid, event)` | DAQ `DataAvailable` listener callback that writes timestamped analog samples to an open file handle as CSV text. |
| `set_analog_recording.m` | `set_analog_recording(hSI, analog_channels)` | Sets up an NI `daq.createSession('ni')` session in the base workspace: builds the analog output filename from ScanImage's log path/stem/counter, adds voltage input channels per `analog_channels`, opens the CSV file, attaches `saveData`/`plotData` as `DataAvailable` listeners. |
| `start_analog_recording.m` | `start_analog_recording(~,~)` | Identical to `SI_user_functions/start_analog_recording.m`. |
| `stop_analog_recording.m` | `stop_analog_recording(src, event, varargin)` | Identical to `SI_user_functions/stop_analog_recording.m`. |
