class CostCentreGroup {
  final String id;
  final String name;
  final bool hidden;

  CostCentreGroup(this.id, this.name, this.hidden);

  CostCentreGroup.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id,
        this.name = json['name'],
        this.hidden = json['hidden'];

  @override
  String toString() {
    return "Cost center: {\n\tid: $id, \n\tname: $name\n}";
  }

  @override
  bool operator ==(costCentreGroup) =>
      costCentreGroup is CostCentreGroup && costCentreGroup.id == id;

  @override
  int get hashCode => id.hashCode;
}
