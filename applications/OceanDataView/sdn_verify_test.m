%SDN_VERIFY_TEST   test for sdn_verify
%
%See also: oceandataview, nerc_verify

% 'SDN_parameter_mapping
sdn_verify('<subject>SDN:LOCAL:PRESSURE</subject><object>SDN:P011::PRESPS01</object><units>SDN:P061::UPDB</units>');
sdn_verify('<subject>SDN:LOCAL:T90</subject><object>SDN:P011::TEMPS901</object><units>SDN:P061::UPAA</units>');
sdn_verify('<subject>SDN:LOCAL:Salinity</subject><object>SDN:P011::PSALPR02</object><units>SDN:P061::UUUU</units>');
sdn_verify('<subject>SDN:LOCAL:fluorescence</subject><object>SDN:P011::CPHLPM01</object><units>SDN:P061::UGPL</units>');
sdn_verify('<subject>SDN:LOCAL:Trans_red_25cm</subject><object>SDN:P011::POPTDR01</object><units>SDN:P061::UPCT</units>');
sdn_verify('<subject>SDN:LOCAL:POTM</subject><object>SDN:P011::POTMCV01</object><units>SDN:P061::UPAA</units>');
sdn_verify('<subject>SDN:LOCAL:Density</subject><object>SDN:P011::SIGTPR01</object><units>SDN:P061::UKMC</units>');

% 'SDN_parameter_mapping
sdn_verify('<subject>SDN:LOCAL:Air_pressure(p)</subject><object>SDN:P011::CAPASS01</object><units>SDN:P061::UPBB</units>');
sdn_verify('<subject>SDN:LOCAL:Wind_direction(dd)</subject><object>SDN:P011::EWDAZZ01</object><units>SDN:P061::UABB</units>');
sdn_verify('<subject>SDN:LOCAL:Wind_speed(ff)</subject><object>SDN:P011::ESSAZZ01</object><units>SDN:P061::UVAA</units>');
sdn_verify('<subject>SDN:LOCAL:Wind_bft(bft)</subject><object>SDN:P011::WMOCWFBF</object><units>SDN:P061::USPC</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_period(pw)</subject><object>SDN:P011::GTCAEV01</object><units>SDN:P061::UTBB</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_height(hw)</subject><object>SDN:P011::GCARVS01</object><units>SDN:P061::ULAA</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_direction_1(dw1)</subject><object>SDN:P011::GDSWEV01</object><units>SDN:P061::UABB</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_period_1(pw1)</subject><object>SDN:P011::GPSWEV01</object><units>SDN:P061::UTBB</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_period_1_code_1(pw1k1)</subject><object>SDN:P011::WMOCWPXX</object><units>SDN:P061::USPC</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_height_1(hw1)</subject><object>SDN:P011::GHSWEV01</object><units>SDN:P061::ULAA</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_direction_2(dw2)</subject><object>SDN:P011::GSD2VS01</object><units>SDN:P061::UABB</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_period_2(pw2)</subject><object>SDN:P011::GSZ2VS01</object><units>SDN:P061::UTBB</units>');
sdn_verify('<subject>SDN:LOCAL:Wave_height_2(hw2) </subject><object>SDN:P011::GCH2VS01</object><units>SDN:P061::ULAA</units>');
sdn_verify('<subject>SDN:LOCAL:Clouds_height(h)</subject><object>SDN:P011::WMOCCBLW</object><units>SDN:P061::USPC</units>');
sdn_verify('<subject>SDN:LOCAL:Cloud_amount(n)</subject><object>SDN:P011::WMOCCCAC</object><units>SDN:P061::USPC</units>');
sdn_verify('<subject>SDN:LOCAL:Amount_lowest_cloud(nh)</subject><object>SDN:P011::WMOCCCLM</object><units>SDN:P061::USPC</units>');
sdn_verify('<subject>SDN:LOCAL:Air_temperature(t)</subject><object>SDN:P011::CDTBSS01</object><units>SDN:P061::UPAA</units>');
sdn_verify('<subject>SDN:LOCAL:Dew-point_temp(td)</subject><object>SDN:P011::CDEWCVWD</object><units>SDN:P061::UPAA</units>');
sdn_verify('<subject>SDN:LOCAL:Wet-bulb_temp (tb)</subject><object>SDN:P011::CWETSS01</object><units>SDN:P061::UPAA</units>');
sdn_verify('<subject>SDN:LOCAL:Sea-surface_temp(tw)</subject><object>SDN:P011::PSSTTS01</object><units>SDN:P061::UPAA</units>');
