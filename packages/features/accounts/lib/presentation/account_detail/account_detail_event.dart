part of 'account_detail_bloc.dart';

/// Events for the account detail BLoC.
sealed class AccountDetailEvent extends Equatable {
  const AccountDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load the detail of a specific account.
final class LoadAccountDetail extends AccountDetailEvent {
  const LoadAccountDetail({required this.accountId});

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}
