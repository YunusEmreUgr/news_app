import 'package:flutter/material.dart';
import 'package:frontend_template/core/enums/view_state.dart';

class ViewStateBuilder extends StatelessWidget {
  final ViewState state;
  final Widget Function(BuildContext context) onSuccess;
  final Widget Function(BuildContext context)? onLoading;
  final Widget Function(BuildContext context, String? errorMessage)? onError;
  final Widget Function(BuildContext context)? onEmpty;
  final String? errorMessage;

  const ViewStateBuilder({
    super.key,
    required this.state,
    required this.onSuccess,
    this.onLoading,
    this.onError,
    this.onEmpty,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.initial:
      case ViewState.loading:
        return onLoading != null
            ? onLoading!(context)
            : const Center(child: CircularProgressIndicator.adaptive());
      case ViewState.error:
        return onError != null
            ? onError!(context, errorMessage)
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    errorMessage ?? 'Bir hata oluştu',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
      case ViewState.empty:
        return onEmpty != null
            ? onEmpty!(context)
            : const Center(child: Text('Gösterilecek veri bulunamadı.'));
      case ViewState.success:
        return onSuccess(context);
    }
  }
}
