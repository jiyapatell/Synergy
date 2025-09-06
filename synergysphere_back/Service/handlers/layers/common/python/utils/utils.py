from datetime import datetime

class Utils:

    @staticmethod
    def get_current_timestamp():
        """
        Get the current timestamp
        Returns:
            str: Current timestamp in ISO format
        """
        return datetime.utcnow().isoformat() + 'Z'
