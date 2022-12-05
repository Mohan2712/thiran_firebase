part of 'get_ticket_from_firebase_bloc.dart';

abstract class GetTicketFromFirebaseState extends Equatable {
  const GetTicketFromFirebaseState();
}

class GetTicketFromFirebaseInitial extends GetTicketFromFirebaseState {
  @override
  List<Object> get props => [];
}

class GetTicketFromFirebaseLoaded extends GetTicketFromFirebaseState {
  final List<AllData> data;

  GetTicketFromFirebaseLoaded({required this.data});

  @override
  List<Object> get props => [data];
}

class GetTicketFromFirebaseError extends GetTicketFromFirebaseState {
  final error;

  GetTicketFromFirebaseError({required this.error});

  @override
  List<Object> get props => [error];
}
