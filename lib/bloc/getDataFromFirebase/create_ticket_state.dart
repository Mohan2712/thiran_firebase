part of 'create_ticket_bloc.dart';

abstract class CreateTicketState extends Equatable {
  const CreateTicketState();
}

class CreateTicketInitial extends CreateTicketState {
  @override
  List<Object> get props => [];
}

class CreateTicketLoaded extends CreateTicketState {
  CreateTicketLoaded();

  @override
  List<Object> get props => [];
}

class CreateTicketError extends CreateTicketState {
  final error;

  CreateTicketError({required this.error});

  @override
  List<Object> get props => [error];
}
