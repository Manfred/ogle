# frozen_string_literal' true

module Ogle
  class Ant
    class Event
      CHANNEL_EVENTS = {
        0x00 => [
          'no_error',
          'Returned on a successful operation'
        ],
        0x01 => [
          'rx_search_timeout',
          'A receive channel has timed out on searching. The search is terminated, and the channel has been automatically closed. In order to restart the search the Open Channel message must be sent again.'
        ],
        0x02 => [
          'rx_fail',
          'A receive channel missed a message which it was expecting. This happens when a follower is tracking a primary and is expecting a message at the set message rate.'
        ],
        0x03 => [
          'tx',
          'A Broadcast message has been transmitted successfully. This event should be used to send the next message for transmission to the ANT device if the node is setup as a primary.'
        ],
        0x04 => [
          'transfer_rx_failed',
          'A receive transfer has failed. This occurs when a Burst Transfer Message was incorrectly received.'
        ],
        0x05 => [
          'transfer_tx_completed',
          'An Acknowledged Data message or a Burst Transfer sequence has been completed successfully. When transmitting Acknowledged Data or Burst Transfer, there is no EVENT_TX message.'
        ],
        0x06 => [
          'transfer_tx_failed',
          'An Acknowledged Data message, or a Burst Transfer Message has been initiated and the transmission failed to complete successfully.'
        ],
        0x07 => [
          'channel_closed',
          'The channel has been successfully closed. When the Host sends a message to close a channel, it first receives a RESPONSE_NO_ERROR to indicate that the message was successfully received by ANT; however, EVENT_CHANNEL_CLOSED is the actual indication of the closure of the channel. As such, the Host must use this event message rather than the RESPONSE_NO_ERROR message to let a channel state machine continue.'
        ],
        0x08 => [
          'rx_fail_go_to_search',
          'The channel has dropped to search mode after missing too many messages.'
        ],
        0x09 => [
          'channel_collision',
          'Two channels have drifted into each other and overlapped in time on the device causing one channel to be blocked.'
        ],
        0x0a => [
          'transfer_tx_start',
          'Sent after a burst transfer begins, effectively on the next channel period after the burst transfer message has been sent to the device.'
        ],
        0x11 => [
          'transfer_next_data_block',
          'Returned to indicate a data block release on the burst buffer.'
        ],
        0x15 => [
          'wrong_state',
          'Returned on attempt to perform an action on a channel that is not valid for the channel’s state.'
        ],
        0x16 => [
          'not_opened',
          'Attempted to transmit data on an unopened channel.'
        ],
        0x18 => [
          'channel_id_not_set',
          'Returned on attempt to open a channel before setting a valid ID.'
        ],
        0x19 => [
          'close_all_channels',
          'Returned when an OpenRxScanMode() command is sent while other channels are open.'
        ],
        0x1f => [
          'transfer_in_progress',
          'Returned on an attempt to communicate on a channel with a transmit transfer in progress.'
        ],
        0x20 => [
          'transfer_sequence_number_error',
          'Returned when sequence number is out of order on a Burst Transfer.'
        ],
        0x21 => [
          'transfer_in_error',
          'Returned when a burst message passes the sequence number check but will not be transmitted due to other reasons.'
        ],
        0x27 => [
          'message_size_exceeded_limit',
          'Returned if a data message is provided that is too large.'
        ],
        0x28 => [
          'invalid_message',
          'Returned when message has invalid parameters.'
        ],
        0x30 => [
          'invalid_network_number',
          'Returned when an invalid network number is provided. As mentioned earlier, valid network numbers are between 0 and MAX_NET-1.'
        ],
        0x31 => [
          'invalid_scan_tx_channel',
          'Returned when attempting to transmit on ANT channel 0 in scan mode.'
        ],
        0x33 => [
          'invalid_parameter_provided',
          'Returned when invalid configuration commands are requested.'
        ],
        0x34 => [
          'serial_que_overflow',
          'This event indicates that the outgoing serial buffer of the USB chip has overflowed. This typically happens if the ANT chip is actively generating serial messages but the PC application is stalled/not running. This event is sent to notify the host application that the message buffer was full and some messages were lost.'
        ],
        0x35 => [
          'event_que_overflow',
          'May be possible when using synchronous serial port, or using all channels on a slow asynchronous connection. Indicates that one or more events were lost due to excessive latency in reading events out over the serial port. This typically happens if the serial queue is full.'
        ],
        0x38 => [
          'encrypt_negotiation_success',
          'When an ANT follower has negotiated successfully with an encrypted ANT primary this event is passed to both the primary and the follower.'
        ],
        0x39 => [
          'encrypt_negotiation_fail',
          'When an ANT slave fails negotiation with an encrypted ANT master this event is passed to both the master and the slave. This can occur due to configuration mismatch, poor RF, mismatched encryption keys, or white/blacklisting by the master .'
        ],
        0x40 => [
          'nvm_full_error',
          'Returned when the NVM for SensRcore mode is full.'
        ],
        0x41 => [
          'nvm_write_error',
          'Returned when writing to the NVM for SensRcore mode fails.'
        ],
        0x70 => [
          'usb_string_write_fail',
          'Returned when configuration of a USB descriptor string fails.'
        ],
        0xae => [
          'mesg_serial_error_id',
          <<~SERIAL_ERROR_ID
            This message is generated if the ANT chip receives a USB data packet that is not correctly formatted. The data portion of this message may be used to debug the USB packet.
            The first byte of the data (usually channel number) is the error number.
            0 – the first byte of the USB data packet was not the ANT serial message Tx sync byte (0xA4)
            2 – the checksum of the ANT message was incorrect
            3 – the size of the ANT message was too large
            The rest of the data is a copy of the message that was sent.
          SERIAL_ERROR_ID
        ]
      }.freeze
    end
  end
end
