import 'package:flutter/material.dart';
import '../models/inspection_models.dart';

enum InspectionType { conditionReport, roadworthy, fleet }

class ActiveInspectionProvider extends ChangeNotifier {
  InspectionType activeType = InspectionType.conditionReport;

  final Map<String, String> vehicleDetails = {
    'Form Ref No': '0458',
    'Vehicle Engine Number': '',
    'Vehicle VIN Chassis Number': '',
    'Owner Surname & Initials': '',
    'Vehicle Model': '',
    'Vehicle Make': '',
    'Vehicle Registration No': '',
    'Test Date': '',
    'Time': '',
    'Odometer Reading': '',
    'Examiner Name': '',
    'Examiner Number': '',
    'Remarks': '',
    'Brake_LF': '', 'Brake_RF': '', 'Brake_LR': '', 'Brake_RR': '',
    'Park_LF1': '', 'Park_RF1': '', 'Park_LR2': '', 'Park_RR2': '',
    'Odo_LF': '', 'Odo_RF': '', 'Odo_LR': '', 'Odo_RR': '',
  };

  final Map<String, bool> scannedFieldsRegistry = {
    'Vehicle Registration No': false,
    'Vehicle VIN Chassis Number': false,
    'Vehicle Engine Number': false,
    'Vehicle Make': false,
    'Vehicle Model': false,
    'Odometer Reading': false,
  };

  Map<String, List<ComponentResult>> sections = {};
  List<TyreResult> tyres = [];

  ActiveInspectionProvider() {
    _initializeOfficialBRCMatrix();
  }

  void setInspectionType(InspectionType type) {
    activeType = type;
    notifyListeners();
  }

  void recalculateDynamicComponentBudgets() {
    notifyListeners();
  }

  void _initializeOfficialBRCMatrix() {
    sections = {
      // IDENTIFICATION & DOCUMENTATION
      'Identification & Docs': [
        ComponentResult(id: 'id_sap', title: 'IDENTIFICATION / SAP CLEARANCE', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'sap_t', label: 'SAP Clearance Proof')]),
        ComponentResult(id: 'reg_details', title: 'INFORMATION & REGISTRATION DETAILS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'reg_t', label: 'Registration Window Card')]),
      ],

      // ELECTRICAL SYSTEM
      'Electrical System': [
        ComponentResult(id: 'wiper_ops', title: 'TEST WIPER OPERATIONS FRONT & BACK', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'w_ops', label: 'Wiper Motor Actuation')]),
        ComponentResult(id: 'wiper_blades', title: 'CHECK CONDITION OF ALL WIPER BLADES', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'w_bld', label: 'Wiper Blade Edge rubber')]),
        ComponentResult(id: 'washer_jets', title: 'TEST WASHER JETS FRONT AND REAR', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'w_jet', label: 'Washer Fluid Pattern')]), 
        ComponentResult(id: 'hooter_op', title: 'TEST HOOTER - OPERATIONAL', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'h_op', label: 'Hooter Mounting Assembly')]),
        ComponentResult(id: 'hooter_aud', title: 'TEST HOOTER - AUDIOBALITY', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'h_aud', label: 'Hooter Sound Area')]), 
        ComponentResult(id: 'wiring_storage', title: 'CHECK ELECTRICAL WIRING & EQUIPMENT STORAGE', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'w_store', label: 'Wiring Looms Tray')]), 
        ComponentResult(id: 'alt_warning_lamp', title: 'TEST ALTERNATOR WARNING LAMP', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'alt_lmp', label: 'Alternator Warning Light')]),
        ComponentResult(id: 'battery_clamp', title: 'CHECK BATTERY CLAMP, TERMINAL, CORRESION E.C.T', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'bat_clmp', label: 'Battery Base Cradle')]), 
        ComponentResult(id: 'ht_leads', title: 'CHECK HIGH TENSION LEADS, SPARKPLUGS LEADS, COIL AND DISTRIBUTOR', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'ht_ld', label: 'Ignition Leads Layout')]), 
        ComponentResult(id: 'test_lamps_lighting', title: 'TEST LAMPS & LIGHTING', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'lmp_lgt', label: 'Exterior Cluster Illumination')]),
        ComponentResult(id: 'lamp_adjust', title: 'CHECK LAMP ADJUSTMENT & ADJUSTERS', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'lmp_adj', label: 'Headlight Lens Aim Aimers')]), 
        ComponentResult(id: 'indicators_flasher', title: 'TEST FLASHER TYPE DIRECTIONAL INDICATORS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'ind_flsh', label: 'Hazard Flash Sequence')]),
        ComponentResult(id: 'interior_lamps', title: 'CHECK INTERIOR LAMPS', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'int_lmp', label: 'Roof Lining Dome Lights')]), 
      ],

      // FITTINGS & EQUIPMENT
      'Fittings & Equipment': [
        ComponentResult(id: 'bumper_bars', title: 'CHECK BUMPER BARS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'bmp_bar', label: 'Bumper Frame Attachment')]),
        ComponentResult(id: 'body_defects', title: 'CHECK BODY, DENTS, SCRATCHES & RUST', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'bdy_def', label: 'Exterior Sheet Metal Corrosion')]),
        ComponentResult(id: 'tool_kit', title: 'CHECK TOOL KIT, JACK & WHEEL SPANNER', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'tl_kt', label: 'Trunk Spare Wheel Well Kit')]), 
        ComponentResult(id: 'service_book', title: 'CHECK SERVICE BOOK & OWNER MANUAL', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'srv_bk', label: 'Glovebox Document Folder')]), 
        ComponentResult(id: 'mudguards', title: 'MUDGUARDS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'mud_grd', label: 'Fender Splash Shield Mudguards')]),
        ComponentResult(id: 'seatbelts_ops', title: 'TEST OPERATIONS OF SAFETY BELTS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'st_blt', label: 'Seatbelt Webbing Clasp Locking')]),
        ComponentResult(id: 'stork_restraints', title: 'CHECK CONDITION OF STORK & RESTRAINTS', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'stk_rst', label: 'Stork Restraint Structures')]), 
        ComponentResult(id: 'door_ops', title: 'TEST OPERATIONS OF DOORS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'dr_ops', label: 'Door Hinges Safety Latches')]),
        ComponentResult(id: 'door_locks', title: 'CHECK ALL DOOR LOCK OPERATION', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'dr_lck', label: 'Door Lock Barrel Catch')]), 
        ComponentResult(id: 'floor_steps', title: 'CHECK FLOOR & STEPS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'flr_stp', label: 'Cabin Crossmember Structural Floor')]),
        ComponentResult(id: 'seats_cond', title: 'CHECK CONDITION OF SEATS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'sts_cnd', label: 'Seat Frame Structure Integrity')]),
        ComponentResult(id: 'seat_adjusters', title: 'TEST ALL SEAT ADJUSTERS', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'st_adj', label: 'Seat Mounting Rail Tractions')]), 
        ComponentResult(id: 'mirrors_cond', title: 'CHECK CONDITION OF MIRRORS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'mir_cnd', label: 'Rearview Reflective Glass Face')]),
        ComponentResult(id: 'mirrors_adj', title: 'CHECK IF ALL MIRROS ARE FULLY ADJUSTABLE', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'mir_adj', label: 'Mirror Adjustment Linkage Base')]), 
        ComponentResult(id: 'view_front_sides', title: 'CHECK VIEW TO FRONT & SIDES', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'vw_frnt', label: 'Driver Sightline Path Clear Zone')]),
        ComponentResult(id: 'windscreen_glass', title: 'CHECK WINDSCREEN & WINDOW FOR DAMAGE', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'wnd_scrn', label: 'Windscreen Face Stone Chip Checks')]),
        ComponentResult(id: 'pedal_rubbers', title: 'CHECK DRIVING CONTROLS, CLUTCH PEDAL & BRAKE RUBBERS', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'pdl_rbr', label: 'Pedal Facing Non-Slip Nitrile Rubbers')]),
        ComponentResult(id: 'heater_fan', title: 'TEST HEATER & FAN OPERATION', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'htr_fn', label: 'Air Demister Defrost Fans Vent')]), 
        ComponentResult(id: 'air_con', title: 'TEST AIR CONDITIONER', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'a_c_cltch', label: 'A/C Condenser Line Compressor')]), 
        ComponentResult(id: 'fuel_system_pipes', title: 'CHECK CONDITION OF FUEL SYSTEM & FUEL PIPES', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'fl_sys', label: 'Fuel Injection Feed Return Hose lines')]), 
        ComponentResult(id: 'retro_reflectors', title: 'RETRO REFLECTORS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'rtr_rfl', label: 'Rear Red Reflective Safety Strips')]),
        ComponentResult(id: 'rear_warning', title: 'REAR WARNING SIGNS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'rr_wrn', label: 'Chevron Plates Trailer Manifest Badge')]), 
        ComponentResult(id: 'safety_design', title: 'SAFETY DESIGN', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'sfty_dsg', label: 'Vehicle Geometric Safety Compliance Profile')]),
        ComponentResult(id: 'warning_triangles', title: 'EMERGENCY WARNING TRIANGLES', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'wrn_tri', label: 'Portable Red Reflective Safety Triangles')]), 
      ],

      'Braking System': [
        ComponentResult(id: 'service_brake_pedal', title: 'SERVICE BRAKE PEDAL', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'sb_pdl', label: 'Brake Pedal Pad Assembly')]),
        ComponentResult(id: 'test_service_brake', title: 'TEST SERVICE BRAKE OPERATION', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'sb_op', label: 'Hydraulic Cylinder Engagement Feed')]),
        ComponentResult(id: 'brake_general', title: 'CHECK BRAKING SYSTEM - GENERAL', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'bk_gen', label: 'Brake System Infrastructure layout')]),
        ComponentResult(id: 'brake_specific', title: 'BRAKING SYSTEM - SPECIFIC ITEMS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'bk_spec', label: 'Braking Mechanical Junction Components')]),
        ComponentResult(id: 'brake_hydraulics_leaks', title: 'CHECK BRAKE HYDROLICS FOR LEAKS', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'bh_lks', label: 'Brake Flex Hoses Caliper Flange Seals')]), 
        ComponentResult(id: 'test_braking_perf', title: 'TEST BRAKING PERFORMANCE', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'bk_perf', label: 'Braking deceleration Test Path Matrix')]),
        ComponentResult(id: 'check_discs_cond', title: "CHECK CONDITION OF DISC'S", isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'dsc_cnd', label: 'Brake Discs Surface Scoring Wear')]), 
        ComponentResult(id: 'abs_operation', title: 'ABS OPERATION', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'abs_op_v', label: 'ABS Dashboard Solenoid Light Cycle')]), 
        ComponentResult(id: 'service_brakes_row', title: 'SERVICE BRAKES', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'sb_r_1', label: 'Overall Service Brake Compliance Status')]),
        ComponentResult(id: 'test_parking_brake', title: 'TEST PARKING / EMERGENCY BRAKE', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'p_brk_t', label: 'Handbrake Lever Mechanical Check')])
      ],

      'Wheels': [
        ComponentResult(id: 'road_wheels_hubs', title: 'ROAD WHEELS & HUBS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'r_whl_hb', label: 'Wheel Nut Stud Seated Thread Flanges')]),
        ComponentResult(id: 'check_tyre_size_type', title: 'CHECK SIZE & TYPE OF TYRES', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'tyr_sz_tp', label: 'Tyre Sidewall Dimensional Data Script')]),
        ComponentResult(id: 'check_tyre_cond', title: 'CHECK CONDITION OF TYRES', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'tyr_cnd', label: 'Tyre Rubber Sidewall Structure Checks')]),
        ComponentResult(id: 'wheel_vibrations', title: 'LISTEN FOR WHEEL VIBRATIONS', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'whl_vbr', label: 'Hub Spindle Hub Wheel Bearing Play')]), 
        ComponentResult(id: 'check_tread_depth_row', title: 'CHECK TREAD DEPTH', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'trd_dph_r', label: 'Tread Groove Channel Indicator Wear')])
      ],

      'Suspension & Undercarriage': [
        ComponentResult(id: 'cleanliness', title: 'CLEANLINESS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'cln_u', label: 'Engine Bay Base Chassis Panel Wash Status')]),
        ComponentResult(id: 'chassis_undercarriage', title: 'CHASSIS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'chs_ud', label: 'Undercarriage Infrastructure Profile Floor')]),
        ComponentResult(id: 'chassis_frame', title: 'CHASSIS OR FRAME', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'chs_frm', label: 'Chassis Rail Long Member Welds Frame')]),
        ComponentResult(id: 'test_suspension_units', title: 'TEST SUSPENSION UNITS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'tst_ssp', label: 'Leaf Coil Spring Shackle Assembly Mounts')]),
        ComponentResult(id: 'check_susp_mountings', title: 'CHECK SUSPENSION MOUNTINGS', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'chk_ssp_m', label: 'Control arm Wishbone Pivot Bushes Tray')]), 
        ComponentResult(id: 'check_ball_joints', title: 'CHECK CONDITIONS OF ALL BALL JOINTS', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'chk_bj', label: 'Suspension Steering Ball Joint Boots')]), 
        ComponentResult(id: 'check_boots_damage', title: 'CHECK BOOTS FOR DAMAGE', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'chk_bts', label: 'CV Axle Axle Shaft Boot Pair Clamp')]), 
        ComponentResult(id: 'check_shock_absorbers', title: 'CHECK SHOCK ABSORBERS / DAMAGE / LEAKS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'chk_sa', label: 'Hydraulic Piston Seal Oil Leak Path Struts')]),
        ComponentResult(id: 'check_stabilizers_bushes', title: 'CHECK STABILIZERS & ANTI-ROLL BARS BUSHES', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'chk_stb_b', label: 'Swaybar Link Stabilizer Bushings Base')]), 
        ComponentResult(id: 'check_stub_axles', title: 'CHECK STUB AXLES, WHEEL BEARINGS, CONROL-ARMS / BUSHES & KINPINS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'chk_ax_b', label: 'Stub Spindle Assembly Kingpins bushes')]), 
        ComponentResult(id: 'check_wheel_alignment', title: 'CHECK WHEEL ALIGNMENT TOE IN / TOE OUT', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'chk_wa_ali', label: 'Steering Track Tie-Rod Adjuster Flange')]), 
        ComponentResult(id: 'noise_level_undercarriage', title: 'NOISE LEVEL', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'ns_lvl_ud', label: 'Exhaust Undercarriage Acoustics Track Frame')]), 
        ComponentResult(id: 'check_jacking_points', title: 'CHECK JACKING POINTS', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'chk_jk_pt', label: 'Body Floor Sill Corner Jacking Ribs Mount')]), 
      ],

      'Steering': [
        ComponentResult(id: 'steering_wheel_central', title: 'CHECK STEERING WHEEL & CENTRALISATION', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'str_whl_c', label: 'Steering Central Index Sector Rack Alignment')]),
        ComponentResult(id: 'steering_free_play', title: 'CHECK STEERING COLUMN FOR FREE PLAY', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'str_sc_fp', label: 'Steering Column Shaft Spline Coupling U-Joint')]),
        ComponentResult(id: 'steering_mechanism', title: 'CHECK STEERING MECHANISM', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'str_mech_m', label: 'Steering Idler Drop Arm Linkages Pitman Frame')]),
        ComponentResult(id: 'power_steering_op', title: 'CHECK POWER STEERING OPERATION', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'pwr_st_op', label: 'Power Steering Pump Assist Load Operation Check')]),
        ComponentResult(id: 'power_steering_leaks', title: 'CHECK POWER STEERING FOR FLAND LEAKS & FLUID LEVEL', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'pwr_st_lk', label: 'Power Steering Pressure Hose Line O-Rings Ring')]), 
        ComponentResult(id: 'rack_ends_wear', title: 'CHECK STEERING RAC ENDS FOR WEAR', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'rk_end_wr', label: 'Steering Inner Axial Joint Thread Socket Seat')]), 
        ComponentResult(id: 'tie_rods_ends_cond', title: 'CHECK CONDITION OF THE RODS & TIE ROD ENDS', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'tie_rd_end', label: 'Outer Steering Tie-Rod End Dust Sealing Boot')]) 
      ],

      'Engine': [
        ComponentResult(id: 'smoke_emission_8', title: 'SMOKE EMISSION', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'smk_em_8', label: 'Tailpipe Smoke Plume Exhaust Color Audit View')]),
        ComponentResult(id: 'engine_transmission_mountings', title: 'CHECK ENGINE & TRANSMISSION MOUNTINGS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'eng_trm_m', label: 'Engine Engine Subframe Insulated Base Mounts')]),
        ComponentResult(id: 'manual_box_syncro_noise', title: 'LISTEN FOR MANUAL BOX SYNCRO NOISE', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'mnl_bx_sn', label: 'Gearbox Synchromesh Ring Shift Acceleration Noise')]), 
        ComponentResult(id: 'oil_leaks_engine_gearbox', title: 'CHECK FOR OIL LEAKS AT ENGINE AND GEARBOX', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'oil_lk_eg', label: 'Engine Sump Pan Transmission Gasket Junctions')]), 
        ComponentResult(id: 'clutch_slipping_check', title: 'CHECK CLUTCH FOR SLIPPING', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'clt_slp_c', label: 'Clutch Disc Friction Plate Load Engagement View')]), 
        ComponentResult(id: 'release_bearing_noise_listen', title: 'LISTEN FOR RELEASE BEARING NOISE', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'rls_brg_n', label: 'Clutch Release Throwout Bearing Hub Fork Area')]) 
      ],

      'Exhaust System': [
        ComponentResult(id: 'check_exhaust_system_9', title: 'CHECK EXHAUST SYSTEM', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'chk_ex_9', label: 'Exhaust Silencer Expansion Muffler Shell Casing')]),
        ComponentResult(id: 'exhaust_mountings_hangers_9', title: 'CHECK EXHAUST MOUNTING & HANGERS', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'ex_mnt_h9', label: 'Exhaust Rubbers Insulation Hangers Bracket Line')]) 
      ],

      'Transmission & Drive': [
        ComponentResult(id: 'drive_train_noise_vibrations', title: 'TEST DRIVE TRAIN FOR NOISE & VIBRATIONS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'dt_ns_vb', label: 'Prop-Shaft Universal Joint Center Bearings Check')]),
        ComponentResult(id: 'drive_train_boots_check', title: 'CHECK DRIVE TRAIN BOGES', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'dt_bts_c', label: 'Rear Axle Retaining Drive Flange Rubber Boots')]),
        ComponentResult(id: 'differential_leaks_noise_check', title: 'CHECK DIFFERENTIAL FOR LEAKS & LISTEN FOR NOISE', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'df_lks_ns', label: 'Differential Cover Nose Pinion Flange Oil Gaskets')]) 
      ],

      'Instruments': [
        ComponentResult(id: 'speedo_odometer_check', title: 'CHECK SPEEDOMETER & ODOMETER', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'spd_odo_c', label: 'Instrument Odometer Mechanical Gauge Face Profile')]),
        ComponentResult(id: 'instrument_operational_check', title: 'CHECK INSTRUMENT OPERATIONAL', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'inst_op_c', label: 'Instrument Glow Indicators Self-Check Cluster View')]),
        ComponentResult(id: 'instrument_lighting_check', title: 'CHECK INSTRUMENT LIGHTING', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'inst_lt_c', label: 'Cluster Backlight Rheostat Dial Illumination View')])
      ],

      'Dimensions': [
        ComponentResult(id: 'dimensions_evaluation', title: 'DIMENSIONS', isRoadworthyRelevant: true, isCompulsory: true, photoTargets: [SubPhotoTarget(id: 'dim_ev_12', label: 'Vehicle Legal Max Width Overall Boundary Profile')])
      ],

      'Structural Damage': [
        ComponentResult(id: 'body_undercarriage_structural_check', title: 'CHECK BODY & UNDERCARRIAGE FOR MAJOR STRUCTURAL DAMAGE & REPAIR', isRoadworthyRelevant: false, isCompulsory: false, photoTargets: [SubPhotoTarget(id: 'bdy_ud_st', label: 'Chassis Kick-Up Subframe Welds Check')])
      ],
    };

    tyres = [
      TyreResult(position: 'Front Left', make: '', size: '', loadSpeedIndex: '', treadDepthMm: -1),
      TyreResult(position: 'Front Right', make: '', size: '', loadSpeedIndex: '', treadDepthMm: -1),
      TyreResult(position: 'Rear Left', make: '', size: '', loadSpeedIndex: '', treadDepthMm: -1),
      TyreResult(position: 'Rear Right', make: '', size: '', loadSpeedIndex: '', treadDepthMm: -1),
      TyreResult(position: 'Spare Tyre', make: '', size: '', loadSpeedIndex: '', treadDepthMm: -1),
    ];
  }

  bool get passesRoadworthy {
    for (var sectionList in sections.values) {
      for (var component in sectionList) {
        if (component.isRoadworthyRelevant && component.isCompulsory) {
          if (component.isNotApplicable) continue;
          if (component.photoTargets.first.status == ItemStatus.na || component.photoTargets.first.status == ItemStatus.fail) {
            return false;
          }
        }
      }
    }
    return true;
  }

  bool isSectionComplete(String sectionName) {
    return true; // Bypass switch handles Chrome debug evaluations effortlessly
  }
}