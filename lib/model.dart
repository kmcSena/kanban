class Task {
  String title;
  int status; // 0:購入 1:発送 2:到着
  Task(this.title, [this.status = 0]);
}
