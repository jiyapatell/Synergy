from typing import Type, Any, Dict, List, Optional

class GenericRepository:
    def __init__(self, model_class: Type):
        self.model_class = model_class

    def create(self, data: Dict[str, Any]) -> Any:
        item = self.model_class(**data)
        item.save()
        return item

    def get(self, item_id: str) -> Optional[Any]:
        try:
            return self.model_class.get(item_id)
        except self.model_class.DoesNotExist:
            return None

    def update(self, item_id: str, updates: Dict[str, Any]) -> Optional[Any]:
        item = self.get(item_id)
        if item:
            for key, value in updates.items():
                setattr(item, key, value)
            item.save()
            return item
        return None

    def delete(self, item_id: str) -> bool:
        item = self.get(item_id)
        if item:
            item.delete()
            return True
        return False

    def list_all(self, filter_condition=None) -> List[Any]:
        if filter_condition:
            return list(self.model_class.scan(filter_condition))
        return list(self.model_class.scan())
