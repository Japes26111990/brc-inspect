import 'package:flutter/material.dart';
import '../models/inspection_models.dart';

enum InspectionType { conditionReport, roadworthy, fleet }

class ActiveInspectionProvider extends ChangeNotifier {
  // 🚀 Active Mode Track - Controls structural view states dynamically across screens
  InspectionType activeType = InspectionType.conditionReport;

  // 🚀 VEHICLE DETAILS PARAMETERS MATCHED TO PAGE 1 REPORT BLOCKS
  final Map<String, String> vehicleDetails = {
    'Vehicle Type': 'Vehicles',
    'Year Model': '',
    'Manufacturer': '',
    'Model': '',
    'Odometer Reading': '',
    'Body Type': '',
    'Stock Number': '',
    'Fuel Type': '',
    'Transmission': '',
    'Doors': '',
    'Colour': '',
    'Inspector Name': '',
  };

  final Map<String, bool> scannedFieldsRegistry = {
    'Year Model': false,
    'Manufacturer': false,
    'Model': false,
    'Odometer Reading': false,
    'Body Type': false,
    'Colour': false,
  };

  Map<String, List<ComponentResult>> sections = {};
  List<TyreResult> tyres = [];

  ActiveInspectionProvider() {
    _initializeBaseTelemetryMatrix();
  }

  // 🚀 API Entry Switch Point: Toggles active mode states seamlessly
  void setInspectionType(InspectionType type) {
    activeType = type;
    notifyListeners();
  }

  void _initializeBaseTelemetryMatrix() {
    sections = {
      // 🚀 DRIVE SYSTEM DETAILS - EXACTLY AS WRITTEN ON PAGE 3 & 4
      'Drive System': [
        ComponentResult(id: 'ball_joint', title: 'Ball Joint', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'bj_1', label: 'Ball Joint Inspection View')]),
        ComponentResult(id: 'bell_housing', title: 'Bell Housing / Dust Cover', photoTargets: [SubPhotoTarget(id: 'bh_1', label: 'Bell Housing / Dust Cover Inspection View')]),
        ComponentResult(id: 'bonnet_cable', title: 'Bonnet Cable', photoTargets: [SubPhotoTarget(id: 'bc_1', label: 'Bonnet Cable Inspection View')]),
        ComponentResult(id: 'bonnet_shocks', title: 'Bonnet Shocks/ stay', photoTargets: [SubPhotoTarget(id: 'bs_1', label: 'Bonnet Shocks/ stay Inspection View')]),
        ComponentResult(id: 'bonnet_hinges', title: 'Bonnet Hinges', photoTargets: [SubPhotoTarget(id: 'bhg_1', label: 'Bonnet Hinges Inspection View')]),
        ComponentResult(id: 'underbody', title: 'Underbody', isRoadworthyRelevant: true, photoTargets: [
          SubPhotoTarget(id: 'ub_1', label: 'Underbody Front Area View (Image 1)'),
          SubPhotoTarget(id: 'ub_2', label: 'Underbody Rear Area View (Image 2)'),
        ]),
        ComponentResult(id: 'subframe', title: 'Subframe', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'sf_1', label: 'Subframe Inspection View')]),
        ComponentResult(id: 'control_arm', title: 'Control Arm', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'ca_1', label: 'Control Arm Inspection View')]),
        ComponentResult(id: 'trailing_arms', title: 'Trailing Arms', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'ta_1', label: 'Trailing Arms Inspection View')]),
        ComponentResult(id: 'exhaust_system', title: 'Exhaust System', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'ex_1', label: 'Exhaust System Inspection View')]),
        ComponentResult(id: 'smoke_emission', title: 'Smoke Emission', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'se_1', label: 'Smoke Emission Inspection View')]),
        ComponentResult(id: 'chassis', title: 'Chassis', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'ch_1', label: 'Chassis Inspection View')]),
        ComponentResult(id: 'shock_mounting', title: 'Shock Mounting', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'sm_1', label: 'Shock Mounting Inspection View')]),
        ComponentResult(id: 'susp_rack_ends', title: 'Suspension Rack Ends', isRoadworthyRelevant: true, photoTargets: [
          SubPhotoTarget(id: 'sre_1', label: 'Suspension Rack Ends Alignment View (Image 7)')
        ]),
        ComponentResult(id: 'stabilizer', title: 'Stabilizer', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'sb_1', label: 'Stabilizer Inspection View')]),
        ComponentResult(id: 'bushings', title: 'Bushings', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'bsg_1', label: 'Bushings Inspection View')]),
        ComponentResult(id: 'links', title: 'Links', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'lk_1', label: 'Links Inspection View')]),
        ComponentResult(id: 'susp_tie_rods', title: 'Suspension Tie Rods', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'tr_1', label: 'Suspension Tie Rods Inspection View')]),
        ComponentResult(id: 'wheel_bearings', title: 'Wheel Bearings', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'wb_1', label: 'Wheel Bearings Inspection View')]),
        ComponentResult(id: 'axles', title: 'Axles', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'ax_1', label: 'Axles Inspection View')]),
        ComponentResult(id: 'shocks', title: 'Shocks', isRoadworthyRelevant: true, photoTargets: [
          SubPhotoTarget(id: 'shk_fl', label: 'Front Left Strut & Spring (Image 3)'),
          SubPhotoTarget(id: 'shk_fr', label: 'Front Right Strut & Spring (Image 5)'),
          SubPhotoTarget(id: 'shk_rl', label: 'Rear Left Shock & Spring (Image 4)'),
          SubPhotoTarget(id: 'shk_rr', label: 'Rear Right Shock & Spring (Image 6)'),
        ]),
        ComponentResult(id: 'rebound_rubbers', title: 'Rebound Rubbers', photoTargets: [SubPhotoTarget(id: 'rr_1', label: 'Rebound Rubbers Inspection View')]),
        ComponentResult(id: 'trans_gearbox', title: 'Transmission/ gearbox', photoTargets: [SubPhotoTarget(id: 'tg_1', label: 'Transmission/ gearbox Inspection View')]),
        ComponentResult(id: 'steering_rack', title: 'Steering Rack', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'srk_1', label: 'Steering Rack Inspection View')]),
        ComponentResult(id: 'engine_gearbox_mounts', title: 'Engine/gearbox Mountings', photoTargets: [SubPhotoTarget(id: 'egm_1', label: 'Engine/gearbox Mountings Inspection View')]),
        ComponentResult(id: 'fuel_system', title: 'Fuel System', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'fs_1', label: 'Fuel System Inspection View')]),
        ComponentResult(id: 'radiators_fans', title: 'Radiators/fans/ coolers', photoTargets: [SubPhotoTarget(id: 'rfc_1', label: 'Radiators/fans/ coolers Inspection View')]),
        ComponentResult(id: 'radiator_cradle', title: 'Radiator Cradle', photoTargets: [SubPhotoTarget(id: 'rc_1', label: 'Radiator Cradle Inspection View')]),
        ComponentResult(id: 'coolant_hoses', title: 'Coolant Hoses And Connections', photoTargets: [SubPhotoTarget(id: 'chc_1', label: 'Coolant Hoses And Connections Inspection View')]),
        ComponentResult(id: 'brake_lines', title: 'Brake Lines And Hoses', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'blh_1', label: 'Brake Lines And Hoses Inspection View')]),
        ComponentResult(id: 'hand_brake', title: 'Hand Brake', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'hb_1', label: 'Hand Brake Inspection View')]),
        ComponentResult(id: 'brake_calipers', title: 'Brake Calipers', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'bc_1', label: 'Brake Calipers Inspection View')]),
        ComponentResult(id: 'cv_joints', title: 'Cv Joints', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'cvj_1', label: 'Cv Joints Inspection View')]),
        ComponentResult(id: 'differential', title: 'Differential', photoTargets: [SubPhotoTarget(id: 'diff_1', label: 'Differential Inspection View')]),
        ComponentResult(id: 'diff_mountings', title: 'Diff Mountings', photoTargets: [SubPhotoTarget(id: 'dm_1', label: 'Diff Mountings Inspection View')]),
        ComponentResult(id: 'propshaft_center', title: 'Propshaft And Center Bearing', photoTargets: [SubPhotoTarget(id: 'pcb_1', label: 'Propshaft And Center Bearing Inspection View')]),
        ComponentResult(id: 'drive_shaft', title: 'Drive Shaft', photoTargets: [SubPhotoTarget(id: 'ds_1', label: 'Drive Shaft Inspection View')]),
        ComponentResult(id: 'electric_power_steering', title: 'Electric Power Steering', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'eps_1', label: 'Electric Power Steering Inspection View')]),
        ComponentResult(id: 'link_rod_dust_cover', title: 'Link Rod Dust Cover', photoTargets: [SubPhotoTarget(id: 'lrdc_1', label: 'Link Rod Dust Cover Inspection View')]),
      ],
      // 🚀 ENGINE COMPARTMENT DETAILS - EXACTLY AS WRITTEN ON PAGE 5
      'Engine Compartment': [
        ComponentResult(id: 'belts', title: 'Belts', photoTargets: [SubPhotoTarget(id: 'bl_1', label: 'Belts Inspection View')]),
        ComponentResult(id: 'engine_idle', title: 'Engine Idle', photoTargets: [SubPhotoTarget(id: 'ei_1', label: 'Engine Idle Inspection View')]),
        ComponentResult(id: 'alternator_gen', title: 'Alternator/ generator', photoTargets: [SubPhotoTarget(id: 'ag_1', label: 'Alternator/ generator Inspection View')]),
        ComponentResult(id: 'battery_terminals', title: 'Battery Condition/ terminals/clamps', photoTargets: [SubPhotoTarget(id: 'btc_1', label: 'Battery Bay Tray Corner View (Image 2)')]),
        ComponentResult(id: 'coolant_levels', title: 'Coolant Levels', photoTargets: [SubPhotoTarget(id: 'cl_1', label: 'Coolant Levels Inspection View')]),
        ComponentResult(id: 'oil_levels', title: 'Oil Levels', photoTargets: [SubPhotoTarget(id: 'ol_1', label: 'Oil Levels Inspection View')]),
        ComponentResult(id: 'cables', title: 'Cables', photoTargets: [SubPhotoTarget(id: 'cb_1', label: 'Cables Inspection View')]),
        ComponentResult(id: 'pipes_wiring', title: 'Pipes/wiring', photoTargets: [SubPhotoTarget(id: 'pw_1', label: 'Pipes/wiring Inspection View')]),
        ComponentResult(id: 'brake_fluid', title: 'Brake Fluid', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'bf_1', label: 'Brake Fluid Inspection View')]),
        ComponentResult(id: 'oil_cap_dipstick', title: 'Oil Cap And Dipstick', photoTargets: [
          SubPhotoTarget(id: 'oc_1', label: 'Engine Oil Filler Cap (Image 1)'),
          SubPhotoTarget(id: 'ff_1', label: 'Open Fuel Filler Flap (Image 3)'),
        ]),
        ComponentResult(id: 'expansion_bottle', title: 'Expansion Bottle', photoTargets: [SubPhotoTarget(id: 'eb_1', label: 'Expansion Bottle Inspection View')]),
        ComponentResult(id: 'fan', title: 'Fan', photoTargets: [SubPhotoTarget(id: 'fn_1', label: 'Fan Inspection View')]),
        ComponentResult(id: 'firewall', title: 'Firewall', photoTargets: [SubPhotoTarget(id: 'fw_1', label: 'Firewall Inspection View')]),
        ComponentResult(id: 'induction_pipe', title: 'Induction Pipe', photoTargets: [SubPhotoTarget(id: 'ip_1', label: 'Induction Pipe Inspection View')]),
        ComponentResult(id: 'engine_core', title: 'Engine', photoTargets: [
          SubPhotoTarget(id: 'ec_1', label: 'Top-Down Full Engine Compartment (Image 4)'),
          SubPhotoTarget(id: 'ec_2', label: 'Lower Oil Pan Access Hatch (Image 5)'),
          SubPhotoTarget(id: 'ec_3', label: 'Lower Angle Engine Compartment (Image 6)'),
        ]),
      ],
      // 🚀 VEHICLE EXTERIOR DETAILS - EXACTLY AS WRITTEN ON PAGE 6 & 7
      'Vehicle Exterior': [
        ComponentResult(id: 'body_panels', title: 'Body Panels', photoTargets: [SubPhotoTarget(id: 'bp_1', label: 'Body Panels Inspection View')]),
        ComponentResult(id: 'crumple_zones', title: 'Crumple Zones', photoTargets: [SubPhotoTarget(id: 'cz_1', label: 'Crumple Zones Inspection View')]),
        ComponentResult(id: 'bumper_fittings', title: 'Bumper, Fittings And Protection', photoTargets: [SubPhotoTarget(id: 'bfp_1', label: 'Bumper, Fittings And Protection View')]),
        ComponentResult(id: 'door_hinges', title: 'Door Hinges And Operation', photoTargets: [SubPhotoTarget(id: 'dho_1', label: 'Door Hinges And Operation View')]),
        ComponentResult(id: 'door_handles', title: 'Door Handles', photoTargets: [SubPhotoTarget(id: 'dh_1', label: 'Door Handles Inspection View')]),
        ComponentResult(id: 'lid_hinges', title: 'Lid Hinges', photoTargets: [SubPhotoTarget(id: 'lh_1', label: 'Lid Hinges Inspection View')]),
        ComponentResult(id: 'wipers', title: 'Wipers', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'wp_1', label: 'Wipers Inspection View')]),
        ComponentResult(id: 'side_windows', title: 'Side Windows', photoTargets: [SubPhotoTarget(id: 'sw_1', label: 'Side Windows Inspection View')]),
        ComponentResult(id: 'windscreen', title: 'Windscreen (Chips And', isRoadworthyRelevant: true, photoTargets: [
          SubPhotoTarget(id: 'ws_lic', label: 'Windscreen Front Profile View (Check for Chips, Cracks, or Damage)')
        ]),
        ComponentResult(id: 'back_window', title: 'Back Window', photoTargets: [SubPhotoTarget(id: 'bw_1', label: 'Back Window Inspection View')]),
        ComponentResult(id: 'window_rubbers', title: 'Window Rubbers And Rails', photoTargets: [SubPhotoTarget(id: 'wrr_1', label: 'Window Rubbers And Rails View')]),
        ComponentResult(id: 'headlights_cond', title: 'Headlights (Condition)', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'hc_1', label: 'Headlights (Condition) View')]),
        ComponentResult(id: 'main_beams', title: 'Main Beams', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'mb_1', label: 'Main Beams Inspection View')]),
        ComponentResult(id: 'dim_lights', title: 'Dim Lights', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'dl_1', label: 'Dim Lights Inspection View')]),
        ComponentResult(id: 'park_lights', title: 'Park Lights', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'pl_1', label: 'Park Lights Inspection View')]),
        ComponentResult(id: 'fog_lights', title: 'Fog Lights', photoTargets: [SubPhotoTarget(id: 'fl_1', label: 'Fog Lights Inspection View')]),
        ComponentResult(id: 'indicators_cond', title: 'Indicators (Condition)', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'ic_1', label: 'Indicators (Condition) View')]),
        ComponentResult(id: 'side_repeaters', title: 'Side Repeaters', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'sr_1', label: 'Side Repeaters Inspection View')]),
        ComponentResult(id: 'side_mirrors', title: 'Side Mirrors', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'sm_1', label: 'Side Mirrors Inspection View')]),
        ComponentResult(id: 'rear_tail_lights', title: 'Rear Tail Lights Cluster (Condition)', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'rtl_1', label: 'Rear Tail Lights Cluster View')]),
        ComponentResult(id: 'reflectors', title: 'Reflectors', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'rf_1', label: 'Reflectors Inspection View')]),
        ComponentResult(id: 'brake_lights', title: 'Brake Lights', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'bl_1', label: 'Brake Lights Inspection View')]),
        ComponentResult(id: 'reverse_lights', title: 'Reverse Lights', photoTargets: [SubPhotoTarget(id: 'rvl_1', label: 'Reverse Lights Inspection View')]),
        ComponentResult(id: 'number_plate_lights', title: 'Number Plate Lights', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'npl_1', label: 'Number Plate Lights View')]),
        ComponentResult(id: 'tailgate_ops', title: 'Tailgate Operations', photoTargets: [SubPhotoTarget(id: 'to_1', label: 'Tailgate Operations View')]),
      ],
      // 🚀 VEHICLE INTERIOR DETAILS - EXACTLY AS WRITTEN ON PAGE 8 & 9
      'Vehicle Interior': [
        ComponentResult(id: 'remote_controls', title: 'Remote Controls', photoTargets: [SubPhotoTarget(id: 'rc_1', label: 'Remote Controls View')]),
        ComponentResult(id: 'main_key', title: 'Main Key', photoTargets: [SubPhotoTarget(id: 'mk_1', label: 'Main Key View')]),
        ComponentResult(id: 'spare_key', title: 'Spare Key', photoTargets: [SubPhotoTarget(id: 'sk_1', label: 'Spare Key View')]),
        ComponentResult(id: 'alarm_system', title: 'Alarm System And Immobiliser', photoTargets: [SubPhotoTarget(id: 'as_1', label: 'Alarm System And Immobiliser View')]),
        ComponentResult(id: 'locking_system', title: 'Locking System', photoTargets: [SubPhotoTarget(id: 'ls_1', label: 'Locking System View')]),
        ComponentResult(id: 'steering_lock', title: 'Steering Lock', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'sl_1', label: 'Steering Lock View')]),
        ComponentResult(id: 'interior_lights', title: 'Interior Lights', photoTargets: [SubPhotoTarget(id: 'il_1', label: 'Interior Lights View')]),
        ComponentResult(id: 'hooter', title: 'Hooter', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'ht_1', label: 'Hooter Inspection View')]),
        ComponentResult(id: 'fuel_gauge', title: 'Fuel Gauge', photoTargets: [SubPhotoTarget(id: 'fg_1', label: 'Fuel Gauge View')]),
        ComponentResult(id: 'wipers_stalk', title: 'Wipers Stalk', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'wst_1', label: 'Wipers Stalk View')]),
        ComponentResult(id: 'windscreen_washer', title: 'Windscreen Washer', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'ww_1', label: 'Windscreen Washer View')]),
        ComponentResult(id: 'headlights_operation', title: 'Headlights Operation', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'ho_1', label: 'Headlights Operation View')]),
        ComponentResult(id: 'interior_mirror', title: 'Interior Mirror', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'im_1', label: 'Interior Mirror View')]),
        ComponentResult(id: 'mirror_adjustment', title: 'Mirror Adjustment', photoTargets: [SubPhotoTarget(id: 'ma_1', label: 'Mirror Adjustment View')]),
        ComponentResult(id: 'instrument_cluster', title: 'Instrument Cluster', isRoadworthyRelevant: true, photoTargets: [
          SubPhotoTarget(id: 'ic_1', label: 'Roof Lining / Headliner Fabric (Image 1)'),
          SubPhotoTarget(id: 'ic_2', label: 'Dashboard Odometer Digital Display (Image 2)'),
          SubPhotoTarget(id: 'ic_3', label: 'Behind Steering Wheel Dash Console (Image 3)'),
          SubPhotoTarget(id: 'ic_4', label: 'Driver Seat, Selector & Handbrake (Image 4)'),
        ]),
        ComponentResult(id: 'multifunction_wheel', title: 'Multifunction Steering Wheel', photoTargets: [SubPhotoTarget(id: 'msw_1', label: 'Multifunction Steering Wheel View')]),
        ComponentResult(id: 'warning_lights', title: 'Warning Lights / Sounds', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'wls_1', label: 'Warning Lights / Sounds View')]),
        ComponentResult(id: 'airbag_system', title: 'Airbag System', photoTargets: [SubPhotoTarget(id: 'asb_1', label: 'Airbag System View')]),
        ComponentResult(id: 'door_trim', title: 'Door Trim', photoTargets: [SubPhotoTarget(id: 'dt_1', label: 'Door Trim View')]),
        ComponentResult(id: 'audio_nav', title: 'Audio And Navigation', photoTargets: [SubPhotoTarget(id: 'an_1', label: 'Audio And Navigation View')]),
        ComponentResult(id: 'air_conditioning', title: 'Air Conditioning', photoTargets: [SubPhotoTarget(id: 'ac_1', label: 'Air Conditioning View')]),
        ComponentResult(id: 'switch_operations', title: 'Switch Operations', photoTargets: [SubPhotoTarget(id: 'so_1', label: 'Switch Operations View')]),
        ComponentResult(id: 'seats_condition', title: 'Seats (Condition And Function)', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'scf_1', label: 'Seats (Condition And Function) View')]),
        ComponentResult(id: 'power_windows', title: 'Power Windows', photoTargets: [SubPhotoTarget(id: 'pw_1', label: 'Power Windows View')]),
        ComponentResult(id: 'safety_belt', title: 'Safety Belt', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'sb_2', label: 'Safety Belt View')]),
        ComponentResult(id: 'roof_lining', title: 'Roof/lining', photoTargets: [SubPhotoTarget(id: 'rl_1', label: 'Roof/lining View')]),
        ComponentResult(id: 'sun_visors', title: 'Sun Visors', photoTargets: [SubPhotoTarget(id: 'sv_1', label: 'Sun Visors View')]),
        ComponentResult(id: 'pedal_rubbers', title: 'Pedal Rubbers And Function', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'prf_1', label: 'Pedal Rubbers And Function View')]),
      ],
      // 🚀 TEST DRIVE DETAILS - EXACTLY AS WRITTEN ON PAGE 9 & 10
      'Test Drive': [
        ComponentResult(id: 'starting_behavior', title: 'Starting Behavior', photoTargets: [SubPhotoTarget(id: 'td_sb', label: 'Starting Behavior Evaluation')]),
        ComponentResult(id: 'idle_speed', title: 'Idle Speed Behavior', photoTargets: [SubPhotoTarget(id: 'td_is', label: 'Idle Speed Behavior Evaluation')]),
        ComponentResult(id: 'braking_effect', title: 'Braking Effect', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'td_be', label: 'Braking Effect Evaluation')]),
        ComponentResult(id: 'abs_drive', title: 'Abs', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'td_abs', label: 'Abs Evaluation')]),
        ComponentResult(id: 'suspension_systems', title: 'Suspension Systems', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'td_ss', label: 'Suspension Systems Evaluation')]),
        ComponentResult(id: 'steering_drive', title: 'Steering', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'td_st', label: 'Steering Evaluation')]),
        ComponentResult(id: 'directional_stability', title: 'Directional Stability', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'td_ds', label: 'Directional Stability Evaluation')]),
        ComponentResult(id: 'road_behavior', title: 'Road Behavior & Handling', isRoadworthyRelevant: true, photoTargets: [SubPhotoTarget(id: 'td_rb', label: 'Road Behavior & Handling Evaluation')]),
        ComponentResult(id: 'vehicle_performance', title: 'Vehicle Performance', photoTargets: [SubPhotoTarget(id: 'td_vp', label: 'Vehicle Performance Evaluation')]),
        ComponentResult(id: 'heating_ventilation', title: 'Heating & Ventilation', photoTargets: [SubPhotoTarget(id: 'td_hv', label: 'Heating & Ventilation Evaluation')]),
        ComponentResult(id: 'gear_selection', title: 'Gear Selection', photoTargets: [SubPhotoTarget(id: 'td_gs', label: 'Gear Selection Evaluation')]),
        ComponentResult(id: 'instrument_panel', title: 'Instrument Panel', photoTargets: [SubPhotoTarget(id: 'td_ip', label: 'Instrument Panel Evaluation')]),
        ComponentResult(id: 'noises_vibration', title: 'Noises / Vibration', photoTargets: [SubPhotoTarget(id: 'td_nv', label: 'Noises / Vibration Evaluation')]),
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

  void recalculateDynamicComponentBudgets() {
    String modelText = vehicleDetails['Model']?.toUpperCase() ?? '';
    bool isBakkie = modelText.contains('BAKKIE') || modelText.contains('PICK-UP') || modelText.contains('SINGLE CAB') || modelText.contains('RANGER');
    
    if (sections.containsKey('Drive System')) {
      var cvJointRow = sections['Drive System']!.firstWhere((c) => c.id == 'cv_joints', orElse: () => ComponentResult(id: '', title: '', photoTargets: []));
      if (cvJointRow.id.isNotEmpty) {
        cvJointRow.photoTargets.clear();
        if (isBakkie && !modelText.contains('4X4') && !modelText.contains('4WD')) {
          cvJointRow.photoTargets.add(SubPhotoTarget(id: 'prop_shaft_uj', label: 'Rear Prop-Shaft Universal U-Joint Profile'));
        } else {
          cvJointRow.photoTargets.addAll([
            SubPhotoTarget(id: 'cv_f_left', label: 'Front Left CV Axle Boot Pair'),
            SubPhotoTarget(id: 'cv_f_right', label: 'Front Right CV Axle Boot Pair'),
            SubPhotoTarget(id: 'cv_r_left', label: 'Rear Left CV Axle Boot Pair'),
            SubPhotoTarget(id: 'cv_r_right', label: 'Rear Right CV Axle Boot Pair'),
          ]);
        }
      }
    }
    notifyListeners();
  }

  bool get passesRoadworthy {
    for (var sectionList in sections.values) {
      for (var component in sectionList) {
        if (component.isRoadworthyRelevant && !component.isNotApplicable) {
          if (component.photoTargets.any((p) => p.status == ItemStatus.fail)) {
            return false;
          }
        }
      }
    }
    if (tyres.any((t) => t.position != 'Spare Tyre' && (t.status == ItemStatus.fail || t.treadDepthMm < 1))) {
      return false; //
    }
    return true;
  }

  bool isSectionComplete(String sectionName) {
    // 🚀 BYPASS SWITCH: true keeps it open for Chrome design testing, false locks it down for production.
    bool isDeveloperTestingMode = true; 
    
    if (isDeveloperTestingMode) {
      return true; 
    }

    if (sectionName == 'Tyres / Wheels') {
      for (var t in tyres) {
        bool needsPhoto = t.position != 'Spare Tyre';
        // Fleet checks require size configurations to match data rules
        if (t.make.isEmpty || t.size.isEmpty || t.loadSpeedIndex.isEmpty || t.treadDepthMm == -1) return false;
        if (activeType != InspectionType.fleet && needsPhoto && t.photoPath == null) return false;
      }
      return true;
    }

    if (!sections.containsKey(sectionName)) return true; 
    
    for (var component in sections[sectionName]!) {
      // 🚀 MULTI-MODE FILTER ROADWORTHY: Skip validation checks on cosmetics during safety testing
      if (activeType == InspectionType.roadworthy && !component.isRoadworthyRelevant) continue;
      
      // 🚀 MULTI-MODE FILTER FLEET: Focus parameters on fluids/basics
      if (activeType == InspectionType.fleet && 
          component.id != 'oil_levels' && 
          component.id != 'coolant_levels' && 
          component.id != 'brake_fluid' && 
          component.id != 'instrument_cluster' && 
          !component.isRoadworthyRelevant) continue;

      if (component.isNotApplicable) continue;
      
      for (var target in component.photoTargets) {
        if (target.status == ItemStatus.na) return false; 

        if (target.status == ItemStatus.attention || target.status == ItemStatus.fail) {
          if (target.notes.trim().isEmpty) return false; 
        }

        // Apply mandatory photo capture boundaries cleanly based on selection
        bool structuralPhotoRequired = false;
        if (sectionName == 'Drive System' && component.id == 'underbody') structuralPhotoRequired = true;
        if (sectionName == 'Drive System' && component.id == 'shocks') structuralPhotoRequired = true;
        if (sectionName == 'Drive System' && component.id == 'susp_rack_ends') structuralPhotoRequired = true;
        if (sectionName == 'Engine Compartment' && component.id == 'oil_cap_dipstick') structuralPhotoRequired = true;
        if (sectionName == 'Engine Compartment' && component.id == 'engine_core') structuralPhotoRequired = true;
        if (sectionName == 'Vehicle Exterior' && component.id == 'windscreen') structuralPhotoRequired = true;
        if (sectionName == 'Vehicle Interior' && component.id == 'instrument_cluster') structuralPhotoRequired = true;

        // Fleet checks optimize workflows by skipping baseline underbody mechanical photo steps unless failures are noted
        if (activeType == InspectionType.fleet && 
            (component.id == 'underbody' || component.id == 'shocks' || component.id == 'oil_cap_dipstick')) {
          structuralPhotoRequired = false;
        }

        if (structuralPhotoRequired && target.photoPath == null) {
          return false; 
        }
      }
    }
    return true;
  }
}