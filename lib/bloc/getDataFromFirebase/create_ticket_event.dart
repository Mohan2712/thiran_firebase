part of 'create_ticket_bloc.dart';

abstract class CreateTicketEvent extends Equatable {
  const CreateTicketEvent();
}

class CreateTicketPostData extends CreateTicketEvent {
  final AllData allData;
  CreateTicketPostData(this.allData);

  @override
  List<Object> get props => [allData];
}
