import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thiranfirebasetask/model/data.dart';

import '../Homepage/homepage.dart';
import '../bloc/getDataFromFirebase/create_ticket_bloc.dart';
import '../utils/strings.dart';

class TicketPage extends StatefulWidget {
  TicketPage({Key? key}) : super(key: key);

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  String? token;
  TextEditingController _description = TextEditingController();
  TextEditingController _dateText = TextEditingController();
  TextEditingController _location = TextEditingController();
  TextEditingController _title = TextEditingController();
  bool check = false;
  bool isShow = false;
  List<XFile>? _imageFileList;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  dynamic _pickImageError;
  String? _retrieveDataError;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  String? date;
  List<String> _firebaseImageUrl = [];
  FirebaseStorage storageReference = FirebaseStorage.instance;

  @override
  void initState() {
    maxWidthController.text = '350';
    maxHeightController.text = '250';
    qualityController.text = '100';
    checkNotifications();
    _dateText.text = _getDateAndTime();
    super.initState();
  }

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    await _displayPickImageDialog(context!,
        (double? maxWidth, double? maxHeight, int? quality) async {
      try {
        final List<XFile>? pickedFileList = await _picker.pickMultiImage(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: quality,
        );
        setState(() {
          _imageFileList = pickedFileList;
          print("IMAGE PICKED${_imageFileList}");
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    });
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add optional parameters'),
            content: Column(
              children: <Widget>[
                TextField(
                  readOnly: true,
                  controller: maxWidthController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      hintText: 'Enter maxWidth if desired'),
                ),
                TextField(
                  readOnly: true,
                  controller: maxHeightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      hintText: 'Enter maxHeight if desired'),
                ),
                TextField(
                  readOnly: true,
                  controller: qualityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: 'Enter quality if desired'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    final double? width = maxWidthController.text.isNotEmpty
                        ? double.parse(maxWidthController.text)
                        : null;
                    final double? height = maxHeightController.text.isNotEmpty
                        ? double.parse(maxHeightController.text)
                        : null;
                    final int? quality = qualityController.text.isNotEmpty
                        ? int.parse(qualityController.text)
                        : null;
                    onPick(width, height, quality);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: BlocProvider<CreateTicketBloc>(
              create: (context) => CreateTicketBloc(),
              child: BlocConsumer<CreateTicketBloc, CreateTicketState>(
                builder: (context, state) {
                  if (state is CreateTicketInitial) {
                    return _initial(context);
                  } else
                    return _initial(context);
                },
                listener: (context, state) {
                  if (state is CreateTicketLoaded) {
                    print("Loaded state");
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Ticket Created Succesfully"),
                        duration: Duration(milliseconds: 1800),
                      ));
                    });
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  }
                  if (state is CreateTicketError) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(state.error.toString()),
                        duration: Duration(milliseconds: 1800),
                        backgroundColor: Colors.red.shade700,
                      ));
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _initial(context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back)),
              SizedBox(
                width: 50,
              ),
              Text(
                "Create a Ticket",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return "* Required";
              } else
                return null;
            },
            controller: _title,
            decoration: InputDecoration(
              labelText: 'Problem Title',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            // inputFormatters: [
            //   LengthLimitingTextInputFormatter(150),
            // ],
            validator: (value) {
              if (value!.isEmpty) {
                return "* Required";
              } else if (value.length > 150) {
                return "Description should not be greater than 150 characters";
              } else
                return null;
            },
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: _description,
            decoration: InputDecoration(
              labelText: 'Problem description',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return "* Required";
              } else
                return null;
            },
            keyboardType: TextInputType.text,
            controller: _location,
            decoration: InputDecoration(
              labelText: 'Location',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            readOnly: true,
            keyboardType: TextInputType.text,
            controller: _dateText,
            decoration: InputDecoration(
              labelText: 'Date',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
            ),
            child: Text(
              'Attachment',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
            ),
            child: SizedBox(
              width: 316,
              height: 48,
              child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(
                                //color: AppColors().lightBlack
                                ))),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () => {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Upload Image',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        onPressed: () async {
                          await Permission.storage.request();
                          var permissionStatus =
                              await Permission.storage.status;
                          //getPermission();
                          if (permissionStatus.isGranted) {
                            _onImageButtonPressed(
                              ImageSource.gallery,
                              context: context,
                            );
                          } else {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Give permission"),
                                duration: Duration(milliseconds: 1800),
                              ));
                            });
                          }
                        },
                        icon: Icon(Icons.add_photo_alternate_outlined),
                        color: Colors.black,
                      ),
                    ],
                  )),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          _handlePreview(context),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                if (formkey.currentState!.validate() &&
                    _imageFileList!.isNotEmpty) {
                  buildShowDialog(context);
                  await uploadFunction(_imageFileList!, _title.text);
                  //  Future.delayed(Duration(seconds: 3));
                  print(_firebaseImageUrl);
                  if (_firebaseImageUrl.isNotEmpty) {
                    BlocProvider.of<CreateTicketBloc>(context).add(
                      CreateTicketPostData(AllData(
                          title: _title.text,
                          description: _description.text,
                          location: _location.text,
                          date: _dateText.text,
                          images: _firebaseImageUrl)),
                    );
                    showNotification();
                  }
                } else {}
              },
              child: Text("Create Ticket")),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Future<void> uploadFunction(List<XFile> file, String name) async {
    for (int i = 0; i < file.length; i++) {
      var imageURL = await addImageToFirebase(file[i], name);
      _firebaseImageUrl.add(imageURL.toString());
      print("Download image URL--------------${_firebaseImageUrl}");
    }
  }

  Future<String> addImageToFirebase(XFile image, String name) async {
    Reference reference = storageReference.ref().child(name).child(image.name);
    UploadTask uploadTask = reference.putFile(File(image.path));
    await uploadTask.whenComplete(() =>
        print("get reference url from firebase${reference.getDownloadURL()}"));
    return await reference.getDownloadURL();
  }

  String _getDateAndTime() {
    date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return date ?? "";
  }

  Widget _handlePreview(BuildContext context) {
    return _previewImages(context);
  }

  Widget _previewImages(BuildContext context) {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      Navigator.pop(context);
      return retrieveError;
    }
    if (_imageFileList != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 22.0),
        child: Container(
          height: MediaQuery.of(context).size.height / 5,
          width: MediaQuery.of(context).size.width,
          child: Semantics(
            label: 'image_picker_example_picked_images',
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              key: UniqueKey(),
              itemBuilder: (BuildContext context, int index) {
                return Semantics(
                  label: 'image_picker_example_picked_image',
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Image.file(
                          File(_imageFileList![index].path),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                          right: -2,
                          top: -9,
                          child: IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.black.withOpacity(0.5),
                                size: 18,
                              ),
                              onPressed: () => setState(() {
                                    _imageFileList!.removeAt(index);
                                    print(
                                        "after cancelling image${_imageFileList!}");
                                  })))
                    ],
                  ),
                );
              },
              itemCount: _imageFileList!.length,
            ),
          ),
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  void showNotification() {
    flutterLocalNotificationsPlugin.show(
        0,
        "Testing",
        "The Request has been created",
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')));
  }

  void checkNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);
