part of 'global_position_bloc.dart';

@freezed
sealed class GlobalPositionState with _$GlobalPositionState {
  const factory GlobalPositionState.initial() = GPInitial;

  const factory GlobalPositionState.loading() = GPLoading;

  const factory GlobalPositionState.loaded({
    required List<Account> accounts,
    required List<Transaction> transactions,
    required String userName,
  }) = GPLoaded;

  const factory GlobalPositionState.error({required String message}) = GPError;
}

extension GPLoadedX on GPLoaded {
  double get totalBalance =>
      accounts.fold(0, (sum, account) => sum + account.balance);
}
