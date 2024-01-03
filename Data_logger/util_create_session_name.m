function util_create_session_name(app)
            %setup recording path based on session parameters - Make
            %compliant with [partial] BIDS and thinking of future NWB
            %📂 MyProject
            %└── 📂 sub-A2929
            %       └── 📂
            %       ses-A2929-200711-acq_0000x-[cond_xx]-[T_xx]-[FOV_xx]-[anes_xxx]-[pharm_xxx]
            %              └── 📂 ophys %optical physiology (Movies, arbitrary scans and analog data)
            %              └── 📂 anat  %anatomical stuff (3D stacks, overviews etc)
            %              └── 📂 derivates
            %  project.yml or project.xml (supported)
            %  sessions.csv
            %  acquisitions.csv
            %  subjects.csv
            
            
            %% gather info about what goes into session name based on check
            %boxes state
            
            session_str = string(sprintf('ses-%s-%s',app.SUBJECT_ID,datestr(now,'YYYYmmDD')));
            
            if app.CheckBox_Condition.Value
                session_str = session_str.append(sprintf("-cond_%s",app.CONDITION));
            end
            
            if app.CheckBox_Timepoint.Value
                session_str = session_str.append(sprintf("-T_%02d",app.TIMEPOINT));
            end

            if app.CheckBox_FOV.Value
                session_str = session_str.append(sprintf("-FOV_%02d",app.FOV));
            end
            
            if app.CheckBox_Anesthesia.Value
                session_str = session_str.append(sprintf("-anes_%s",app.ANESTHESIA));
            end
            
            if app.CheckBox_Pharmacology.Value
                session_str = session_str.append(sprintf("-pharm_%s",app.PHARMACOL));
            end

            app.SESSION_ID = session_str;
            app.SessionIDTextArea.Value = app.SESSION_ID;
            
            
            %%
            path_to_session= fullfile(app.PROJECT_ROOT_DIR,app.SUBJECT_ID,cell2mat(app.SESSION_ID));
            app.PATH_TO_SESSION_DATA_OPHYS = fullfile(path_to_session,'ophys');
            app.PATH_TO_SESSION_DATA_ANAT = fullfile(path_to_session,'anat');
            app.PATH_TO_SESSION_DERIVATIVES = fullfile(path_to_session,'derivates');
       
            
            
            
            
            try
                %create data structure
                fprintf('\n\tInitializing session directory.\n')
                if ~isfolder(app.PATH_TO_SESSION_DATA_OPHYS);mkdir(app.PATH_TO_SESSION_DATA_OPHYS);end
                if ~isfolder(app.PATH_TO_SESSION_DATA_ANAT);mkdir(app.PATH_TO_SESSION_DATA_ANAT);end
                if ~isfolder(app.PATH_TO_SESSION_DERIVATIVES);mkdir(app.PATH_TO_SESSION_DERIVATIVES);end
            catch
                warndlg('Failed to initialize session data structure')
                return
            end