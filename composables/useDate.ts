import dayjs from 'dayjs';
import utc from 'dayjs/plugin/utc';
import timezone from 'dayjs/plugin/timezone';

// dayjs のセットアップ
dayjs.extend(utc);
dayjs.extend(timezone);

// デフォルトのタイムゾーンを日本時間に設定
const JST_TIMEZONE = 'Asia/Tokyo';

export const useDate = () => {
  /**
   * 現在時刻を日本時間 (JST) の YYYY-MM-DD 形式で取得する
   */
  const getTodayJST = () => {
    return dayjs().tz(JST_TIMEZONE).format('YYYY-MM-DD');
  };

  /**
   * 指定した日付（または現在時刻）を日本時間の YYYY-MM-DD 形式にフォーマットする
   */
  const formatToJSTDate = (date: string | number | Date | dayjs.Dayjs = new Date()) => {
    return dayjs(date).tz(JST_TIMEZONE).format('YYYY-MM-DD');
  };

  return {
    dayjs, // 必要に応じて dayjs 本体のインスタンスも提供
    getTodayJST,
    formatToJSTDate,
  };
};
