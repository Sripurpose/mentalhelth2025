import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerList({
  double height = 100,
  double width = double.infinity,
  int list = 3,
  double shimmerHeight = 80,
}) {
  return SizedBox(
    height: height,
    width: width,
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: list,
        itemBuilder: (context, index) {
          return Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(height: shimmerHeight),
          );
        },
      ),
    ),
  );
}

Widget shimmerView({required Size size}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.03,
                width: size.width * 0.3,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Card(
                    elevation: 1.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const SizedBox(height: 8),
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.025,
                width: size.width * 0.4,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Card(
                    elevation: 1.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const SizedBox(height: 8),
                  ),
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    height: size.height * 0.025,
                    width: size.width * 0.07,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Card(
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const SizedBox(height: 8),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.025,
                    width: size.width * 0.15,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Card(
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const SizedBox(height: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: size.height * 0.05,
            width: size.width * 0.05,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Card(
                elevation: 1.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const SizedBox(height: 8),
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        height: size.height * 0.03,
        width: size.width * 0.4,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 2),
      SizedBox(
        height: size.height * 0.02,
        width: size.width * 0.8,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      SizedBox(
        height: size.height * 0.02,
        width: size.width * 0.5,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 15),
      SizedBox(
        height: size.height * 0.023,
        width: size.width * 0.14,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 2),
      SizedBox(
        height: size.height * 0.1,
        width: size.width,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(
        height: 23,
      ),
      SizedBox(
        height: size.height * 0.023,
        width: size.width * 0.14,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 4),
      SizedBox(
        height: size.height * 0.3,
        width: size.width,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      SizedBox(
        height: size.height * 0.023,
        width: size.width * 0.14,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 4),
      SizedBox(
        height: size.height * 0.3,
        width: size.width,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 28),
      SizedBox(
        height: size.height * 0.023,
        width: size.width * 0.14,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 6),
      SizedBox(
        height: size.height * 0.3,
        width: size.width,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 19),
      SizedBox(
        height: size.height * 0.023,
        width: size.width * 0.2,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 3),
      SizedBox(
        height: size.height * 0.03,
        width: size.width * 0.5,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 22),
      SizedBox(
        height: size.height * 0.023,
        width: size.width * 0.14,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(
        height: 6,
      ),
      SizedBox(
        height: size.height * 0.023,
        width: size.width * 0.14,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 22),
      SizedBox(
        height: size.height * 0.023,
        width: size.width * 0.2,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 3),
      SizedBox(
        height: size.height * 0.03,
        width: size.width * 0.5,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 29),
      SizedBox(
        height: size.height * 0.029,
        width: size.width * 0.5,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 4),
      SizedBox(
        height: size.height * 0.023,
        width: size.width * 0.14,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 33),
      SizedBox(
        height: size.height * 0.029,
        width: size.width * 0.5,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
      const SizedBox(height: 4),
      SizedBox(
        height: size.height * 0.023,
        width: size.width * 0.14,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(height: 8),
          ),
        ),
      ),
    ],
  );
}
