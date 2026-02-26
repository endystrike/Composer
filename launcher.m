SW_SKU        = 'ZZ_SW_CAI';
AUX_AES_KEY   = 'HK4#r!5pz#=dj!,-';
AUX_LIC_PATH  = 'Composer';
[curr_ver, ~] = t_ver();

if licensing.f_check_startup(SW_SKU, curr_ver, AUX_AES_KEY, AUX_LIC_PATH)
    GUImode = 1;
    CodeWriterApp;
else
    clear;
    exit;
end