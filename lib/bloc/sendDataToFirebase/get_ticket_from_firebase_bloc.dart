import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:thiranfirebasetask/model/data.dart';

import '../../repository/repo.dart';

part 'get_ticket_from_firebase_event.dart';
part 'get_ticket_from_firebase_state.dart';

final repo = Repo();

class GetTicketFromFirebaseBloc
    extends Bloc<GetTicketFromFirebaseEvent, GetTicketFromFirebaseState> {
  GetTicketFromFirebaseBloc() : super(GetTicketFromFirebaseInitial()) {
    on<GetTicketFromFirebaseData>((event, emit) async {
      emit(GetTicketFromFirebaseInitial());
      try {
        var datas = await repo.getAllTicket().first;
        print("data from database $datas");
        emit(GetTicketFromFirebaseLoaded(data: datas));
      } catch (e) {
        emit(GetTicketFromFirebaseError(error: e.toString()));
      }
    });
  }
}
