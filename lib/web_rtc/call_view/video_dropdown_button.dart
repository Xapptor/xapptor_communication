import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/call_view/set_local_renderer.dart';
import 'package:xapptor_communication/web_rtc/custom_dropdown_button.dart';

extension StateExtension on CallViewState {
  CustomDropdownButton video_dropdown_button() {
    return CustomDropdownButton(
      value: current_video_device.value,
      on_changed: (new_value) {
        set_local_renderer(new_value!);
      },
      items: video_devices.value.map((e) => e.label).toList(),
      title: widget.text_list[1],
    );
  }
}
