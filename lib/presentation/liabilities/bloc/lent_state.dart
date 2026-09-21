import '../../../data/models/lent.dart';

class LentState {
  final bool isLoading;
  final List<Lent> lents;
  const LentState({required this.isLoading, required this.lents});
  const LentState.initial() : this(isLoading: true, lents: const []);
}