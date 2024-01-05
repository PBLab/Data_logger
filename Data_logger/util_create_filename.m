function filename = util_create_filename(app)

filename = sprintf("%s-acq_%05d-cond_%s-fov_%02d-T_%02d",...
app.SUBJECT_ID,app.ACQ_ID,app.CONDITION,app.FOV,app.TIMEPOINT)

  