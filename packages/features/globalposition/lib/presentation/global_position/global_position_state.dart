part of 'global_position_bloc.dart';

/// States for the global position BLoC.
sealed class GlobalPositionState extends Equatable {
  const GlobalPositionState();

  @override
  List<Object?> get props => [];
}

/// Initial state before data is loaded.
final class GPInitial extends GlobalPositionState {
  const GPInitial();
}

/// Data is being loaded.
final class GPLoading extends GlobalPositionState {
  const GPLoading();
}

/// Data loaded successfully.
final class GPLoaded extends GlobalPositionState {
  const GPLoaded({
    required this.accounts,
    required this.transactions,
    required this.userName,
  });

  /// User's bank accounts.
  final List<Account> accounts;

  /// Recent transactions across all accounts.
  final List<Transaction> transactions;

  /// User's display name for greeting.
  final String userName;

  /// Total balance across all accounts.
  double get totalBalance =>
      accounts.fold(0, (sum, account) => sum + account.balance);

  @override
  List<Object?> get props => [accounts, transactions, userName];
}

/// An error occurred while loading data.
final class GPError extends GlobalPositionState {
  const GPError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
