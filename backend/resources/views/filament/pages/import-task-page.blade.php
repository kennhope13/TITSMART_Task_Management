<x-filament-panels::page>
    <div class="space-y-6">
        <div class="p-6 bg-white rounded-xl shadow-sm border border-gray-200 dark:border-gray-800">
            <h2 class="text-lg font-bold text-gray-800 mb-4">1. Tải lên danh sách công việc (Excel/CSV)</h2>
            <form wire:submit.prevent="preview" class="space-y-4">
                {{ $this->form }}

                <div class="flex items-center gap-3 mt-4">
                    <x-filament::button type="submit" icon="heroicon-m-magnifying-glass">
                        Phân tích & Preview dữ liệu
                    </x-filament::button>

                    <a href="#" class="text-sm font-medium text-blue-600 hover:underline">
                        📥 Tải file mẫu Excel (.xlsx)
                    </a>
                </div>
            </form>
        </div>

        @if($isUploaded)
            <div class="p-6 bg-white rounded-xl shadow-sm border border-gray-200 dark:border-gray-800">
                <div class="flex items-center justify-between mb-4">
                    <div>
                        <h2 class="text-lg font-bold text-gray-800">2. Màn hình Preview dữ liệu trước khi lưu</h2>
                        <p class="text-sm text-gray-500">Kiểm tra các dòng hợp lệ và lỗi trước khi bấm lưu vào cơ sở dữ liệu.</p>
                    </div>

                    <div class="flex items-center gap-3">
                        <span class="px-3 py-1 bg-emerald-100 text-emerald-800 rounded-full text-xs font-bold">
                            ✅ {{ $validCount }} Dòng hợp lệ
                        </span>
                        <span class="px-3 py-1 bg-rose-100 text-rose-800 rounded-full text-xs font-bold">
                            ❌ {{ $errorCount }} Dòng bị lỗi
                        </span>
                    </div>
                </div>

                <div class="overflow-x-auto border rounded-lg">
                    <table class="w-full text-sm text-left text-gray-700">
                        <thead class="bg-gray-50 font-bold border-b text-xs uppercase text-gray-600">
                            <tr>
                                <th class="p-3">Dòng</th>
                                <th class="p-3">Mã CV</th>
                                <th class="p-3">Tên công việc</th>
                                <th class="p-3">Địa điểm</th>
                                <th class="p-3">Hạn hoàn thành</th>
                                <th class="p-3">Trạng thái</th>
                                <th class="p-3">Chi tiết lỗi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y">
                            @foreach($previewRows as $row)
                                <tr class="{{ $row['is_valid'] ? 'bg-white hover:bg-gray-50' : 'bg-rose-50/50 hover:bg-rose-50' }}">
                                    <td class="p-3 font-semibold">{{ $row['row'] }}</td>
                                    <td class="p-3 font-mono font-bold">{{ $row['code'] }}</td>
                                    <td class="p-3">{{ $row['title'] }}</td>
                                    <td class="p-3">{{ $row['location'] ?: '—' }}</td>
                                    <td class="p-3">{{ $row['due_date'] }}</td>
                                    <td class="p-3">
                                        @if($row['is_valid'])
                                            <span class="px-2 py-1 text-xs font-semibold bg-emerald-100 text-emerald-700 rounded">Hợp lệ</span>
                                        @else
                                            <span class="px-2 py-1 text-xs font-semibold bg-rose-100 text-rose-700 rounded">Lỗi</span>
                                        @endif
                                    </td>
                                    <td class="p-3 text-xs text-rose-600 font-medium">
                                        {{ $row['error'] ?: '—' }}
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>

                <div class="flex items-center justify-between mt-6">
                    @if($errorCount > 0)
                        <x-filament::button color="gray" icon="heroicon-m-arrow-down-tray">
                            Xuất file báo lỗi Excel (.xlsx)
                        </x-filament::button>
                    @else
                        <div></div>
                    @endif

                    <x-filament::button 
                        wire:click="confirmImport" 
                        color="success" 
                        icon="heroicon-m-check-circle"
                        :disabled="$validCount === 0"
                    >
                        Xác nhận lưu {{ $validCount }} công việc hợp lệ
                    </x-filament::button>
                </div>
            </div>
        @endif
    </div>
</x-filament-panels::page>
