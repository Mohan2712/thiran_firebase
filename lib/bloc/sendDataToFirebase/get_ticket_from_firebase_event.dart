part of 'get_ticket_from_firebase_bloc.dart';

abstract class GetTicketFromFirebaseEvent extends Equatable {
  const GetTicketFromFirebaseEvent();
}

class GetTicketFromFirebaseData extends GetTicketFromFirebaseEvent {
  GetTicketFromFirebaseData();

  @override
  List<Object> get props => [];
}
