part of 'global_position_bloc.dart';

enum GlobalPositionStatus { initial, loading, loaded, error }

extension GlobalPositionStatusX on GlobalPositionStatus {
  bool get isInitial => this == GlobalPositionStatus.initial;
  bool get isLoading => this == GlobalPositionStatus.loading;
  bool get isLoaded => this == GlobalPositionStatus.loaded;
  bool get isError => this == GlobalPositionStatus.error;
}

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
