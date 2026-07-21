<div style="background-color: #ffffff; border: 1px solid #c2c6d6; border-radius: 0.75rem; padding: 1.25rem; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
    <div style="display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #f1f5f9; padding-bottom: 0.75rem; margin-bottom: 1rem;">
        <div style="display: flex; align-items: center; gap: 0.5rem;">
            <div style="width: 28px; height: 28px; border-radius: 0.5rem; background-color: #eff6ff; display: flex; align-items: center; justify-content: center;">
                <x-heroicon-o-clock style="width: 18px; height: 18px; color: #0058be;" />
            </div>
            <h3 style="font-weight: 700; font-size: 0.95rem; color: #1e293b; margin: 0;">Nhật ký hoạt động</h3>
        </div>
        <span style="background-color: #f0fdf4; color: #16a34a; border: 1px solid #bbf7d0; font-size: 0.7rem; font-weight: 700; padding: 0.2rem 0.5rem; border-radius: 9999px;">
            Real-time
        </span>
    </div>

    <div style="display: flex; flex-direction: column; gap: 0.75rem;">
        @forelse($this->getActivities() as $item)
            <div style="display: flex; align-items: flex-start; gap: 0.75rem; background-color: #f8fafc; padding: 0.75rem; border-radius: 0.625rem; border: 1px solid #f1f5f9;">
                <div style="width: 34px; height: 34px; shrink: 0; border-radius: 0.5rem; display: flex; align-items: center; justify-content: center; background-color: {{ $item['type'] === 'attendance' ? '#e0f2fe' : '#f0fdf4' }}; color: {{ $item['type'] === 'attendance' ? '#0284c7' : '#16a34a' }};">
                    @if($item['type'] === 'attendance')
                        <x-heroicon-o-map-pin style="width: 18px; height: 18px;" />
                    @else
                        <x-heroicon-o-clipboard-document-check style="width: 18px; height: 18px;" />
                    @endif
                </div>

                <div style="flex: 1; min-width: 0;">
                    <div style="display: flex; align-items: center; justify-content: space-between; gap: 0.5rem;">
                        <p style="font-weight: 700; font-size: 0.825rem; color: #0f172a; margin: 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            {{ $item['title'] }}
                        </p>
                    </div>

                    <p style="font-size: 0.75rem; color: #64748b; margin: 0.2rem 0 0 0; word-break: break-word;">
                        {{ $item['sub'] }}
                    </p>

                    <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 0.4rem;">
                        @if($item['is_fake'])
                            <span style="background-color: #fff1f0; color: #ba1a1a; border: 1px solid #ffdad6; font-size: 0.675rem; font-weight: 700; padding: 0.15rem 0.4rem; border-radius: 0.375rem;">
                                ⚠️ Cảnh báo Fake GPS
                            </span>
                        @else
                            <span></span>
                        @endif

                        <span style="font-size: 0.675rem; color: #94a3b8; white-space: nowrap;">
                            {{ $item['time'] }}
                        </span>
                    </div>
                </div>
            </div>
        @empty
            <p style="font-size: 0.8rem; color: #94a3b8; padding: 1rem 0; text-align: center; margin: 0;">
                Chưa có hoạt động nào gần đây
            </p>
        @endforelse
    </div>
</div>
