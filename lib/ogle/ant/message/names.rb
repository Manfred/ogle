# frozen_string_literal: true

module Ogle
  class Ant
    class Message
      NAMES = {
        0xa4 => 'tx_sync',
        0xa5 => 'rx_sync',
        0x00 => 'invalid_id',
        0x01 => 'event_id',
        0x3e => 'version_id',
        0x40 => 'response_event_id',
        0x41 => 'unassign_channel_id',
        0x42 => 'assign_channel_id',
        0x43 => 'channel_mesg_period_id',
        0x44 => 'channel_search_timeout_id',
        0x45 => 'channel_radio_freq_id',
        0x46 => 'network_key_id',
        0x47 => 'radio_tx_power_id',
        0x48 => 'radio_cw_mode_id',
        0x4a => 'system_reset_id',
        0x4b => 'open_channel_id',
        0x4c => 'close_channel_id',
        0x4d => 'request_id',
        0x4e => 'broadcast_data_id',
        0x4f => 'acknowledged_data_id',
        0x50 => 'burst_data_id',
        0x51 => 'channel_id_id',
        0x52 => 'channel_status_id',
        0x53 => 'radio_cw_init_id',
        0x54 => 'capabilities_id',
        0x55 => 'stacklimit_id',
        0x56 => 'script_data_id',
        0x57 => 'script_cmd_id',
        0x59 => 'id_list_add_id',
        0x5a => 'id_list_config_id',
        0x5b => 'open_rx_scan_id',
        0x5c => 'ext_channel_radio_freq_id',
        0x5d => 'ext_broadcast_data_id',
        0x5e => 'ext_acknowledged_data_id',
        0x5f => 'ext_burst_data_id',
        0x60 => 'channel_radio_tx_power_id',
        0x61 => 'get_serial_num_id',
        0x62 => 'get_temp_cal_id',
        0x63 => 'set_lp_search_timeout_id',
        0x64 => 'set_tx_search_on_next_id',
        0x65 => 'serial_num_set_channel_id_id',
        0x66 => 'rx_ext_mesgs_enable_id',
        0x67 => 'radio_config_always_id',
        0x68 => 'enable_led_flash_id',
        0x6d => 'xtal_enable_id',
        0x6e => 'antlib_config_id',
        0x6f => 'startup_mesg_id',
        0x70 => 'auto_freq_config_id',
        0x71 => 'prox_search_config_id',
        0x72 => 'adv_burst_data_id',
        0x74 => 'event_buffering_config_id',
        0x75 => 'set_search_ch_priority_id',
        0x77 => 'high_duty_search_mode_id',
        0x78 => 'config_adv_burst_id',
        0x79 => 'event_filter_config_id',
        0x7a => 'sdu_config_id',
        0x7b => 'sdu_set_mask_id',
        0x7c => 'user_config_page_id',
        0x7d => 'encrypt_enable_id',
        0x7e => 'set_crypto_key_id',
        0x7f => 'set_crypto_info_id',
        0x80 => 'cube_cmd_id',
        0x81 => 'active_search_sharing_id',
        0x83 => 'nvm_crypto_key_ops_id',
        0x8d => 'get_pin_diode_control_id',
        0x8e => 'pin_diode_control_id',
        0x90 => 'set_channel_input_mask_id',
        0x91 => 'set_channel_data_type_id',
        0x92 => 'read_pins_for_sect_id',
        0x93 => 'timer_select_id',
        0x94 => 'atod_settings_id',
        0x95 => 'set_shared_address_id',
        0x96 => 'atod_external_enable_id',
        0x97 => 'atod_pin_setup_id',
        0x98 => 'setup_alarm_id',
        0x99 => 'alarm_variable_modify_test_id',
        0x9a => 'partial_reset_id',
        0x9b => 'overwrite_temp_cal_id',
        0x9c => 'serial_passthru_settings_id',
        0xaa => 'bist_id',
        0xad => 'unlock_interface_id',
        0xae => 'serial_error_id',
        0xaf => 'set_id_string_id',
        0xb4 => 'port_get_io_state_id',
        0xb5 => 'port_set_io_state_id',
        0xc0 => 'rssi_id',
        0xc1 => 'rssi_broadcast_data_id',
        0xc2 => 'rssi_acknowledged_data_id',
        0xc3 => 'rssi_burst_data_id',
        0xc4 => 'rssi_search_threshold_id',
        0xc5 => 'sleep_id',
        0xc6 => 'get_grmn_esn_id',
        0xc7 => 'set_usb_info_id',
        0xc8 => 'hci_command_complete',
        0xe0 => 'ext_id_0',
        0xe1 => 'ext_id_1',
        0xe2 => 'ext_id_2',
        0xe000 => 'ext_response_id',
        0xe100 => 'ext_request_id',
        0xe220 => 'memdev_eeprom_init_id',
        0xe221 => 'memdev_flash_init_id'
      }.freeze
    end
  end
end
