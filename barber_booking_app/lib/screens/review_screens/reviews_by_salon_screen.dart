import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/providers/review_providers/get_reviews_salon_provider.dart';
import 'package:barber_booking_app/widgets/review_widgets/review_salon_title.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';

class ReviewsBySalonScreen extends StatefulWidget {
  final String salonId;

  const ReviewsBySalonScreen({super.key, required this.salonId});

  @override
  State<ReviewsBySalonScreen> createState() => _ReviewsBySalonScreenState();
}

class _ReviewsBySalonScreenState extends State<ReviewsBySalonScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageParams _initialParams = PageParams(Page: 1, PageSize: 10);
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  void _loadInitial() {
    final provider = Provider.of<GetReviewsSalonProvider>(context, listen: false);
    provider.getReviewsSalon(widget.salonId, _initialParams).then((_) {
      setState(() {
        _hasMore = provider.reviewsList?.length == _initialParams.PageSize;
      });
    });
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    final provider = Provider.of<GetReviewsSalonProvider>(context, listen: false);
    final currentCount = provider.reviewsList?.length ?? 0;
    final pageSize = _initialParams.PageSize ?? 10;
    final nextPage = (currentCount ~/ pageSize) + 1;
    final params = PageParams(Page: nextPage, PageSize: _initialParams.PageSize);

    final result = await provider.getReviewsSalon(widget.salonId, params);
    if (result == true) {
      final newCount = provider.reviewsList?.length ?? 0;
      setState(() {
        _hasMore = newCount > currentCount; 
      });
    }
    setState(() => _isLoadingMore = false);
  }

  Future<void> _refresh() async {
    final provider = Provider.of<GetReviewsSalonProvider>(context, listen: false);
    final pageSize = _initialParams.PageSize ?? 10;
    await provider.getReviewsSalon(widget.salonId, _initialParams);
    setState(() {
      _hasMore = (provider.reviewsList?.length ?? 0) >= pageSize;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetReviewsSalonProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Все отзывы'),
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(GetReviewsSalonProvider provider) {
    if (provider.isLoading && (provider.reviewsList == null || provider.reviewsList!.isEmpty)) {
      return const Center(child: LoadingIndicator(message: 'Загрузка отзывов...'));
    }

    if (provider.errorMessage != null && (provider.reviewsList == null || provider.reviewsList!.isEmpty)) {
      return Center(
        child: ErrorWidgetCustom(
          message: provider.errorMessage!,
          onRetry: () => provider.getReviewsSalon(widget.salonId, _initialParams),
        ),
      );
    }

    if (provider.reviewsList == null || provider.reviewsList!.isEmpty) {
      return const Center(
        child: Text(
          'У салона пока нет отзывов',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final reviews = provider.reviewsList!;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == reviews.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final review = reviews[index];
          return ReviewSalonTitle(review: review);
        },
      ),
    );
  }
}