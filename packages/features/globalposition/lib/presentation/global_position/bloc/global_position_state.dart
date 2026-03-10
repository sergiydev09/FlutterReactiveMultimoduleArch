part of 'global_position_bloc.dart';

enum GlobalPositionStatus { initial, loading, loaded, error }

@freezed
abstract class GlobalPositionState with _$GlobalPositionState {
  const factory GlobalPositionState({
    @Default(GlobalPositionStatus.initial) GlobalPositionStatus status,
    @Default([]) List<Account> accounts,
    @Default([]) List<Transaction> transactions,
    @Default('') String userName,
    @Default('') String errorMessage,
  }) = _GlobalPositionState;

  const GlobalPositionState._();

  double get totalBalance =>
      accounts.fold(0, (sum, account) => sum + account.balance);
}
