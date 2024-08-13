import 'package:fe/utils/api_paths.dart';
import 'package:flutter/material.dart';
import 'package:fe/classes/ride_class.dart';

class RideCard extends StatelessWidget {
  final Ride ride;
  const RideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyleM = theme.textTheme.titleMedium;
    final titleStyleS = theme.textTheme.titleSmall;
    final String imgUrl =
        '$baseUrl/users/${ride.driverUsername}/image';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/singleride', arguments: ride.id);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(imgUrl),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ride.driverUsername,
                        style: titleStyleM,
                      ),
                    ],
                  ),
                  Container(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(height: 5),
                        Text("${ride.from}", style: titleStyleM),
                        const Icon(Icons.arrow_circle_down_rounded),
                        Text("${ride.to}", style: titleStyleM),
                        Container(height: 10),
                        Text("Date ${ride.getDateTime.substring(0, 10)}",
                            style: titleStyleS),
                        Text("Time ${ride.getDateTime.substring(11, 16)}",
                            style: titleStyleS)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
