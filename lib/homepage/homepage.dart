import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/sendDataToFirebase/get_ticket_from_firebase_bloc.dart';
import '../model/data.dart';
import '../ticketpage/ticketpage.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  List<AllData> _data = [];
  bool _check = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 110,
                ),
                Text(
                  "HomePage",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                ),
                SizedBox(
                  width: 20,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TicketPage()));
                    },
                    child: Text("New Ticket")),
              ],
            ),
            Divider(
              color: Colors.black,
              thickness: 0.5,
            ),
            SizedBox(
              height: 10,
            ),
            BlocProvider<GetTicketFromFirebaseBloc>(
              create: (context) =>
                  GetTicketFromFirebaseBloc()..add(GetTicketFromFirebaseData()),
              child: BlocBuilder<GetTicketFromFirebaseBloc,
                  GetTicketFromFirebaseState>(
                builder: (context, state) {
                  if (state is GetTicketFromFirebaseError) {
                    _check = false;
                    print("error check well");
                  }
                  if (state is GetTicketFromFirebaseLoaded) {
                    _check = false;
                    _data = state.data;
                    print(_data);
                    if (_data.isNotEmpty) {
                      return loaded(context, _data);
                    }
                  }

                  return _check
                      ? CircularProgressIndicator()
                      : Text("No data available");
                },
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget loaded(BuildContext context, List<AllData> data) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: CarouselSlider(
                            options: CarouselOptions(height: 400.0),
                            items: data[index].images.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.network(
                                      i
                                          .toString()
                                          .replaceAll('[', "")
                                          .replaceAll(']', ''),
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          data[index].title.toString(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          data[index].description.toString(),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          data[index].date.toString(),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          data[index].location.toString(),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
