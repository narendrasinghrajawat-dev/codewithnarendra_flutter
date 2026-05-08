import 'package:flutter/material.dart';

/// Column definition for admin data table
class AdminDataColumn {
  final String key;
  final String title;
  final double? width;
  final bool sortable;
  final Widget Function(dynamic row)? cellBuilder;

  const AdminDataColumn({
    required this.key,
    required this.title,
    this.width,
    this.sortable = false,
    this.cellBuilder,
  });
}

/// Reusable admin data table with sorting, pagination, and actions
class AdminDataTable extends StatefulWidget {
  final List<AdminDataColumn> columns;
  final List<dynamic> data;
  final bool isLoading;
  final String? emptyMessage;
  final Function(int index, dynamic row)? onEdit;
  final Function(int index, dynamic row)? onDelete;
  final Function(int index, dynamic row)? onView;
  final Function(String columnKey, bool ascending)? onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final int currentPage;
  final Function(int page)? onPageChanged;
  final int? totalPages;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.data,
    this.isLoading = false,
    this.emptyMessage,
    this.onEdit,
    this.onDelete,
    this.onView,
    this.onSort,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.rowsPerPage = 10,
    this.currentPage = 0,
    this.onPageChanged,
    this.totalPages,
  });

  @override
  State<AdminDataTable> createState() => _AdminDataTableState();
}

class _AdminDataTableState extends State<AdminDataTable> {
  int? _hoveredRow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.isLoading) {
      return _buildLoadingState(context);
    }

    if (widget.data.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    return Column(
      children: [
        // Table
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return _buildMobileTable(context, isDark);
                }
                return _buildDesktopTable(context, isDark);
              },
            ),
          ),
        ),
        // Pagination
        if (widget.totalPages != null && widget.totalPages! > 1)
          _buildPagination(context, isDark),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage ?? 'No data available',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, bool isDark) {
    return Table(
      columnWidths: {
        for (int i = 0; i < widget.columns.length; i++)
          i: widget.columns[i].width != null
              ? FixedColumnWidth(widget.columns[i].width!)
              : const FlexColumnWidth(),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              ),
            ),
          ),
          children: widget.columns.asMap().entries.map((entry) {
            final index = entry.key;
            final column = entry.value;
            final isSorted = widget.sortColumnIndex == index;

            return InkWell(
              onTap: column.sortable && widget.onSort != null
                  ? () => widget.onSort!(
                        column.key,
                        !(widget.sortAscending && isSorted),
                      )
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        column.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    if (column.sortable)
                      Icon(
                        isSorted
                            ? (widget.sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                            : Icons.unfold_more,
                        size: 16,
                        color: isSorted
                            ? Theme.of(context).primaryColor
                            : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        // Data rows
        ...widget.data.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;

          return TableRow(
            decoration: BoxDecoration(
              color: _hoveredRow == index
                  ? (isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade50)
                  : (index % 2 == 0
                      ? (isDark ? Colors.grey.shade900 : Colors.white)
                      : (isDark ? Colors.grey.shade900.withOpacity(0.7) : Colors.grey.shade50.withOpacity(0.5))),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                ),
              ),
            ),
            children: [
              ...widget.columns.map((column) {
                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredRow = index),
                  onExit: (_) => setState(() => _hoveredRow = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: column.cellBuilder?.call(row) ??
                        Text(
                          row[column.key]?.toString() ?? '-',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                          ),
                        ),
                  ),
                );
              }),
              // Actions column
              if (widget.onEdit != null || widget.onDelete != null || widget.onView != null)
                MouseRegion(
                  onEnter: (_) => setState(() => _hoveredRow = index),
                  onExit: (_) => setState(() => _hoveredRow = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.onView != null)
                          _buildActionButton(
                            icon: Icons.visibility_outlined,
                            color: Colors.blue,
                            onTap: () => widget.onView!(index, row),
                          ),
                        if (widget.onEdit != null)
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            color: Colors.orange,
                            onTap: () => widget.onEdit!(index, row),
                          ),
                        if (widget.onDelete != null)
                          _buildActionButton(
                            icon: Icons.delete_outline,
                            color: Colors.red,
                            onTap: () => widget.onDelete!(index, row),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMobileTable(BuildContext context, bool isDark) {
    return Column(
      children: widget.data.asMap().entries.map((entry) {
        final index = entry.key;
        final row = entry.value;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.columns.map((column) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            column.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: column.cellBuilder?.call(row) ??
                              Text(
                                row[column.key]?.toString() ?? '-',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                                ),
                              ),
                        ),
                      ],
                    ),
                  );
                }),
                if (widget.onEdit != null || widget.onDelete != null || widget.onView != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.onView != null)
                          _buildActionButton(
                            icon: Icons.visibility_outlined,
                            color: Colors.blue,
                            onTap: () => widget.onView!(index, row),
                          ),
                        if (widget.onEdit != null)
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            color: Colors.orange,
                            onTap: () => widget.onEdit!(index, row),
                          ),
                        if (widget.onDelete != null)
                          _buildActionButton(
                            icon: Icons.delete_outline,
                            color: Colors.red,
                            onTap: () => widget.onDelete!(index, row),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: widget.currentPage > 0
                ? () => widget.onPageChanged?.call(widget.currentPage - 1)
                : null,
            icon: Icon(
              Icons.chevron_left,
              color: widget.currentPage > 0
                  ? (isDark ? Colors.white70 : Colors.black54)
                  : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.currentPage + 1} / ${widget.totalPages}',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: widget.currentPage < (widget.totalPages ?? 1) - 1
                ? () => widget.onPageChanged?.call(widget.currentPage + 1)
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: widget.currentPage < (widget.totalPages ?? 1) - 1
                  ? (isDark ? Colors.white70 : Colors.black54)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
