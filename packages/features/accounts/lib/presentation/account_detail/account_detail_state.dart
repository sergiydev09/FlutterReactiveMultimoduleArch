part of 'account_detail_bloc.dart';

/// States for the account detail BLoC.
sealed class AccountDetailState extends Equatable {
  const AccountDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
final class AccountDetailInitial extends AccountDetailState {
  const AccountDetailInitial();
}

/// Account detail is being loaded.
final class AccountDetailLoading extends AccountDetailState {
  const AccountDetailLoading();
}

/// Account detail loaded successfully.
final class AccountDetailLoaded extends AccountDetailState {
  const AccountDetailLoaded({required this.account});

  final Account account;

  @override
  List<Object?> get props => [account];
}

/// Error loading account detail.
final class AccountDetailError extends AccountDetailState {
  const AccountDetailError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
