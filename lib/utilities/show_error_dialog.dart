import 'package:flutter/material.dart';

Future<void> errorDialog(BuildContext context,String contents){
  return showDialog<void>(context: context, builder: (context)=>
      AlertDialog(
        title: const Text('警告'),
        content: Text(contents),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: const Text('知道了'))
        ],
      ));
}
