// ignore_for_file: unused_element, use_build_context_synchronously

import 'dart:convert';

import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/connection/check_connection.dart';
import 'package:badminton_management_1/bbcontroll/notify_controll.dart';
import 'package:badminton_management_1/bbcontroll/rollcall_controll.dart';
import 'package:badminton_management_1/bbcontroll/session_controll.dart';
import 'package:badminton_management_1/bbcontroll/state/list_student_provider.dart';
import 'package:badminton_management_1/bbcontroll/weather_controll.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_weather.dart';
import 'package:badminton_management_1/ccui/aamenu/weather_widget.dart';
import 'package:badminton_management_1/ccui/abmain/coach/list_coach_view.dart';
import 'package:badminton_management_1/ccui/abmain/coach/list_student_view.dart';
import 'package:badminton_management_1/ccui/abmain/home_header.dart';
import 'package:badminton_management_1/ccui/ccresource/app_resources.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeCoachView extends StatefulWidget {
  const HomeCoachView({super.key});

  @override
  State<HomeCoachView> createState() => _HomeCoachView();
}

class _HomeCoachView extends State<HomeCoachView> {
  NotifyControll notifyControll = NotifyControll();
  WeatherControll weatherControll = WeatherControll();
  final currentUser = MyCurrentUser();
  final currentWeather = MyCurrentWather();
  final sessionManager = SessionManager();

  double valueAnimate = 0;

  @override
  void initState() {
    super.initState();

    notifyControll.checkRollCallCoachs(context);
    sessionManager.startSession(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListStudentProvider>().setListOnline(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không có học viên trong khung giờ này"),
            duration: Duration(seconds: 2),
          ),
        );
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: HomeHeaderView(body: _body(context)));
  }

  Widget _body(BuildContext context) {
    return Container(
        width: AppMainsize.mainWidth(context),
        color: AppColors.pageBackground,
        clipBehavior: Clip.none,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _containerWeather(context),
              const SizedBox(
                height: 30,
              ),
              _buttonRollCallCoachs(context),
              const SizedBox(
                height: 15,
              ),
              _buttonRollCall(context),
              const SizedBox(
                height: 15,
              ),
              _buttonLessonPlan(context),
              const SizedBox(
                height: 15,
              ),
              currentUser.userTypeId == "2"
                  ? _buttonRollCallCoachHistory(context)
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ));
  }

  Widget _containerWeather(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchWeatherData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildWeatherContainer("Đang tải...", "N/A", null, "01d");
        } else if (snapshot.hasError || !snapshot.hasData) {
          return _buildWeatherContainer(
              "Không xác định", "Lỗi dữ liệu", null, "01d");
        }

        var data = snapshot.data!;
        return _buildWeatherContainer(
          data["city"],
          data["description"],
          data["temperature"],
          data["icon"],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchWeatherData() async {
    try {
      Position position = await _determinePosition();
      String apiKey =
          "62c8370f658f2457db00ee12eaa5b07d"; // Thay bằng API Key của bạn
      String url =
          "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric&lang=vi";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return {
          "city": data["name"],
          "description": data["weather"][0]["description"],
          "temperature": data["main"]["temp"],
          "icon": data["weather"][0]["icon"],
        };
      } else {
        throw Exception("Lỗi khi tải dữ liệu thời tiết.");
      }
    } catch (e) {
      return {}; // Trả về rỗng nếu có lỗi
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Dịch vụ vị trí bị tắt.");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        throw Exception("Quyền vị trí bị từ chối.");
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Quyền vị trí bị từ chối vĩnh viễn.");
    }
    return await Geolocator.getCurrentPosition();
  }

  Widget _buildWeatherContainer(
      String city, String description, double? temp, String icon) {
    return Container(
      width: 300,
      height: 200,
      margin: const EdgeInsets.all(10),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hình ảnh biểu tượng thời tiết
                Expanded(
                    flex: 2,
                    child: WeatherWidget(
                        weatherCondition: currentWeather.main ?? "clear")),
                const SizedBox(
                  width: 15,
                ),
                const SizedBox(width: 15),

                // Thông tin thời tiết
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Nhiệt độ',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      Text(
                        '${temp?.toStringAsFixed(1) ?? 'N/A'} °C',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Thời tiết',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                            fontSize: 16, fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonRollCall(BuildContext context) {
    return Consumer<ListStudentProvider>(
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () async {
            bool isConnect = await ConnectionService().checkConnect();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ListStudentView(
                          isConnect: isConnect,
                        )));
          },
          child: Container(
            width: AppMainsize.mainWidth(context) - 100,
            height: 70,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20)),
            child: Center(
                child: Text(
              AppLocalizations.of(context).translate("rollcall_student"),
              style: AppTextstyle.subWhiteTitleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
          ),
        );
      },
    );
  }

  Widget _buttonRollCallCoachHistory(BuildContext context) {
    return Consumer<ListStudentProvider>(
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () async {
            bool isConnect = await ConnectionService().checkConnect();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ListCoachView(
                          isConnect: isConnect,
                        )));
          },
          child: Container(
            width: AppMainsize.mainWidth(context) - 100,
            height: 70,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20)),
            child: Center(
                child: Text(
              AppLocalizations.of(context).translate("rollcall_coach"),
              style: AppTextstyle.subWhiteTitleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
          ),
        );
      },
    );
  }

  bool isRollCall = false;
  Widget _buttonRollCallCoachs(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          isRollCall = true;
        });
        await RollCallControll().rollCallCoachs(context);
        setState(() {
          isRollCall = false;
        });
      },
      child: Container(
        width: AppMainsize.mainWidth(context) - 100,
        height: 70,
        decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
        child: Center(
            child: isRollCall
                ? const CircularProgressIndicator(
                    color: AppColors.pageBackground,
                  )
                : Text(
                    AppLocalizations.of(context).translate("rollcall"),
                    style: AppTextstyle.subWhiteTitleStyle,
                  )),
      ),
    );
  }

  Widget _buttonLessonPlan(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final url = currentUser.linkURL;
        if (url != null && await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          _showErrorDialog(context); // Hiển thị hộp thoại thông báo
        }
      },
      child: Container(
        width: AppMainsize.mainWidth(context) - 100,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context).translate("lessonPlan"),
            style: AppTextstyle.subWhiteTitleStyle,
          ),
        ),
      ),
    );
  }

// Hàm hiển thị hộp thoại thông báo khi không tìm thấy URL
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lỗi"),
          content:
              const Text("Không thể mở đường link! Vui lòng kiểm tra lại."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
