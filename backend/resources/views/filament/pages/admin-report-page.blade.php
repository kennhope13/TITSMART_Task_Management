<x-filament-panels::page>
    <div class="space-y-6">
        <!-- Filter Bar -->
        <div class="p-6 bg-white rounded-xl shadow-sm border border-gray-200">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4 items-end">
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Loại báo cáo</label>
                    <select wire:model.live="reportType" wire:change="generateReport" class="w-full border-gray-300 rounded-lg text-sm focus:ring-blue-500 focus:border-blue-500">
                        <option value="manager">📊 Báo cáo theo Quản lý / Leader</option>
                        <option value="team">👥 Báo cáo theo Đội nhóm</option>
                        <option value="worker">👷 Báo cáo theo Thợ thi công</option>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Từ ngày</label>
                    <input type="date" wire:model="startDate" class="w-full border-gray-300 rounded-lg text-sm">
                </div>

                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Đến ngày</label>
                    <input type="date" wire:model="endDate" class="w-full border-gray-300 rounded-lg text-sm">
                </div>

                <div class="flex gap-2">
                    <x-filament::button wire:click="generateReport" color="primary" class="w-full">
                        Lọc dữ liệu
                    </x-filament::button>
                    <x-filament::button wire:click="exportExcel" color="success" icon="heroicon-m-arrow-down-tray">
                        Xuất Excel
                    </x-filament::button>
                </div>
            </div>
        </div>

        <!-- Table Data -->
        <div class="p-6 bg-white rounded-xl shadow-sm border border-gray-200">
            <h3 class="text-base font-bold text-gray-800 mb-4">
                Bảng thống kê kết quả công việc & tỷ lệ hoàn thành
            </h3>

            <div class="overflow-x-auto border rounded-lg">
                <table class="w-full text-sm text-left text-gray-700">
                    <thead class="bg-gray-50 font-bold border-b text-xs uppercase text-gray-600">
                        <tr>
                            <th class="p-3">Mã / Đơn vị</th>
                            <th class="p-3">Tên Quản lý / Đội / Thợ</th>
                            <th class="p-3 text-center">Tổng công việc</th>
                            <th class="p-3 text-center">Đang làm</th>
                            <th class="p-3 text-center">Đã hoàn thành</th>
                            <th class="p-3 text-center">Trễ hạn</th>
                            <th class="p-3 text-center">Tỷ lệ hoàn thành</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y">
                        @forelse($reportData as $row)
                            @php
                                $rate = $row['total'] > 0 ? round(($row['completed'] / $row['total']) * 100, 1) : 0;
                            @endphp
                            <tr class="hover:bg-gray-50">
                                <td class="p-3 font-mono font-bold">{{ $row['code'] }}</td>
                                <td class="p-3 font-semibold">{{ $row['name'] }}</td>
                                <td class="p-3 text-center font-bold text-gray-800">{{ $row['total'] }}</td>
                                <td class="p-3 text-center text-purple-600 font-semibold">{{ $row['in_progress'] }}</td>
                                <td class="p-3 text-center text-emerald-600 font-semibold">{{ $row['completed'] }}</td>
                                <td class="p-3 text-center text-rose-600 font-semibold">{{ $row['overdue'] }}</td>
                                <td class="p-3 text-center">
                                    <span class="px-2.5 py-1 text-xs font-bold rounded-full {{ $rate >= 80 ? 'bg-emerald-100 text-emerald-800' : ($rate >= 50 ? 'bg-amber-100 text-amber-800' : 'bg-rose-100 text-rose-800') }}">
                                        {{ $rate }}%
                                    </span>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="7" class="p-4 text-center text-gray-500">Chưa có dữ liệu báo cáo</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</x-filament-panels::page>
