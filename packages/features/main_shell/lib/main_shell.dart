/// Main shell feature module — app shell with dynamic navigation.
library;

export 'data/datasources/shell_config_datasource.dart';
export 'data/repositories/shell_session_repository_impl.dart';
export 'di/main_shell_providers.dart';
export 'domain/entities/bottom_tab.dart';
export 'domain/entities/drawer_item.dart';
export 'domain/entities/menu_icon.dart';
export 'domain/entities/shell_config.dart';
export 'domain/repositories/shell_config_repository.dart';
export 'domain/repositories/shell_session_repository.dart';
export 'domain/usecases/get_shell_config_usecase.dart';
export 'domain/usecases/shell_logout_usecase.dart';
export 'presentation/shell/bloc/main_shell_bloc.dart';
export 'presentation/shell/page/main_shell_page.dart';
export 'routing/main_shell_routes.dart';
