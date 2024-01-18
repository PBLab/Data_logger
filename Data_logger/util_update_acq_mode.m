function util_update_acq_mode(app)
% Enable SI modality based on user choice

switch app.APP_MODE
    case 'SI-Online'
        acq_mode = app.DatatypeDropDown.Value;
        switch acq_mode
            case 'Movie'
                cmd = 'hSIcopy.hStackManager.enable=0;';
            case 'Stack'
                cmd = 'hSIcopy.hStackManager.enable=1;';
            case 'Arbitrary Scan'
                 cmd = 'hSIcopy.hStackManager.enable=0;';      
        end%acq_mode
        evalin('base',cmd)
end