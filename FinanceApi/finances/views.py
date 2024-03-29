from rest_framework import viewsets, generics
from .serializer import UserSerializers, UsersTransactionSerializer, TransactionSerializer
from .models.user import User
from .models.transaction import Transaction



class UsersViewSet(viewsets.ModelViewSet):
    """
    Viewset for managing users.

    This viewset provides CRUD operations for managing users.

    Attributes:
        queryset (QuerySet): The queryset of all users.
        serializer_class (Serializer): The serializer class for user objects.
    """
    queryset = User.objects.all()
    serializer_class = UserSerializers

class UsersTransactionList(generics.ListAPIView):
    """
    ListAPIView for retrieving user transactions.

    This view provides a read-only endpoint for retrieving transactions
    associated with a specific user.

    Attributes:
        serializer_class (Serializer): The serializer class for transaction objects.
    """
    serializer_class = UsersTransactionSerializer
    ordering_fields = ['created_at']
    def get_queryset(self):
        """
        Get the queryset of transactions for the specified user.

        Returns:
            QuerySet: The queryset of transactions filtered by the user ID.
        """
        queryset = Transaction.objects.filter(user_id=self.kwargs['pk'])
        return queryset

class TransactionViewSet(viewsets.ModelViewSet):
    """
    Viewset for managing transactions.

    This viewset provides CRUD operations for managing transactions.

    Attributes:
        queryset (QuerySet): The queryset of all transactions.
        serializer_class (Serializer): The serializer class for transaction objects.
    """
    queryset = Transaction.objects.all()
    serializer_class = TransactionSerializer

    def perform_create(self, serializer):
        """
        Perform actions before creating a new transaction.

        Args:
            serializer (Serializer): The serializer instance for the transaction.

        Returns:
            Response: The response after creating the transaction.
        """
        data = self.request.data
        user_id = data['user']
        value = data['value']
        isDebt = data['is_debt']
        user = User.objects.get(id=user_id)
        user.modify_amount(value, isDebt)
        return super().perform_create(serializer)

    def perform_update(self, serializer):
        """
        Perform actions before updating an existing transaction.

        Args:
            serializer (Serializer): The serializer instance for the transaction.

        Returns:
            Response: The response after updating the transaction.
        """
        user_id = self.request.data.get('user')
        user = User.objects.get(id=user_id)
        instance = self.get_object()
        old_value = instance.value
        old_is_debt = instance.is_debt
        user.modify_amount(old_value, not old_is_debt)  # Revert original transaction
        new_value = serializer.validated_data.get('value', old_value)
        new_is_debt = serializer.validated_data.get('is_debt', old_is_debt)
        user.modify_amount(new_value, new_is_debt)  # Apply the new transaction
        return super().perform_update(serializer)

    def perform_destroy(self, instance):
        """
        Perform actions before deleting a transaction.

        Args:
            instance: The transaction instance to be deleted.

        Returns:
            Response: The response after deleting the transaction.
        """
        user_id = instance.user_id
        value = instance.value
        isDebt = instance.is_debt

        user = User.objects.get(id=user_id)
        user.modify_amount(value, not isDebt)

        return super().perform_destroy(instance)
