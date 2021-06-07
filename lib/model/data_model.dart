class FidiData {
  String name;
  String desc;
  String url;
  String minicount;
  String maxcount;
  String image;
  FidiData({this.name, this.desc, this.url, this.minicount, this.maxcount,this.image});
  FidiData.map(dynamic obj) {
    this.name = obj['name'];
    this.desc = obj['Desc'];
    this.url = obj['url'];
    this.minicount = obj['Minicount'];
    this.maxcount = obj['Maxcount'];
    this.image=obj['image'];

  }
  String get names => name;
  String get Desc => desc;
  String get urls => url;
  String get Minicount => minicount;
  String get Maxcount => maxcount;
  String get images => image;

  Map<String ,dynamic> toMap(){
    var map=new Map<String,dynamic>();
    map['name']=name;
    map['Desc']=desc;
    map['url']=url;
    map['Minicount']=minicount;
    map['Maxcount']=maxcount;
    map['image']=image;

    return map;
  }
  FidiData.fromMap(Map<String,dynamic> map){
    this.name=map['name'];
    this.desc=map['Desc'];
    this.url=map['url'];
    this.minicount=map['Minicount'];
    this.maxcount=map['Maxcount'];
    this.image=map['image'];

  }
}