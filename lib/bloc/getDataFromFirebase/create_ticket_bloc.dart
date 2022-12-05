import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/data.dart';
import '../../repository/repo.dart';

part 'create_ticket_event.dart';
part 'create_ticket_state.dart';

final repo = Repo();

class CreateTicketBloc extends Bloc<CreateTicketEvent, CreateTicketState> {
  CreateTicketBloc() : super(CreateTicketInitial()) {
    on<CreateTicketPostData>((event, emit) async {
      emit(CreateTicketInitial());
      try {
        await repo.createTicket(AllData(
            title: event.allData.title,
            description: event.allData.description,
            location: event.allData.location,
            date: event.allData.date,
            images: event.allData.images));
        emit(CreateTicketLoaded());
      } catch (e) {
        emit(CreateTicketError(error: e.toString()));
      }
    });
  }
}
