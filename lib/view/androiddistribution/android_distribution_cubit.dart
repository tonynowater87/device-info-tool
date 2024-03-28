import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'android_distribution_state.dart';

class AndroidDistributionCubit extends Cubit<AndroidDistributionState> {
  AndroidDistributionCubit() : super(AndroidDistributionInitial());
}
