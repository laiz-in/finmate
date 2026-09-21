import '../../../data/models/owe.dart';

class OweState {
  final bool isLoading;
  final List<Owe> owes;
  const OweState({required this.isLoading, required this.owes});
  const OweState.initial() : this(isLoading: true, owes: const []);
}