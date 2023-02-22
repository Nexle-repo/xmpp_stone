abstract class QueueApi<T> {
  QueueApi();
  put(T content);
  resume();

  bool isEligible(T content);
  Future<bool> execute(T content);
  Future<bool> pop();
  clear();
}
